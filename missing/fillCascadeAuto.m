% fillCascadeAuto uses an autoencoder but adds cascading nodes that rely on the autoencoder's hidden layer as well as each other to fill missing data.
function [filledX] = fillCascadeAuto(missingX, completeX, missingMask, arg)
	[completeIndices, missIndices, missCount] = getCompleteIndices(missingX, missingMask);

	% Sort the missing values by frequency.
	[~, idx] = sort(missCount);
	missIndices = missIndices(idx);

	% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
	missingX = fillNaive(missingX, completeX, missingMask, arg);
	trainData = [completeX; missingX];
	trainMask = [ones(size(completeX)); missingMask];

	if ~isfield(arg, 'zmuv')
		arg.zmuv = false;
	end
	if ~isfield(arg, 'zmuvFromComplete')
		arg.zmuvFromComplete = false;
	end
	if arg.zmuvFromComplete
		mn = mean(completeX, 'omitnan');
		st = std(completeX, 'omitnan');
		completeX = (completeX - mn) ./ st;
	elseif arg.zmuv
		mn = mean(trainData, 'omitnan');
		st = std(trainData, 'omitnan');
		trainData = (trainData - mn) ./ st;
	end

	% Train
	model.params = arg;
	model = reset(model);
	model = learn(model, trainData(:, completeIndices), trainData(:, missIndices), trainMask(:, missIndices));

	% Predict
	missY = predict(model, missingX(:, completeIndices), missingX(:, missIndices), missingMask(:, missIndices));

	filledX = missingX;
	filledX(:, missIndices) = missY(:, 1:length(missIndices)); % Predict the missing value.

	if arg.zmuv || arg.zmuvFromComplete
		filledX = (filledX .* st) + mn;
	end
end

function [self] = reset(self)
	if ~isfield(self, 'params')
		self.params = struct();
	end
	if ~isfield(self.params, 'nh')
		self.params.nh = 5;
	end
	if ~isfield(self.params, 'epsilon')
		self.params.epsilon = 1e-7; % Optimal is somewhere around 1e-6 or 1e-7 at 100 epochs and 0.99 rho
	end
	if ~isfield(self.params, 'epochs')
		self.params.epochs = 200;
	end
	if ~isfield(self.params, 'rho')
		self.params.rho = 0.99; % .997 performs slightly better, but .999 is much worse
	end
	if ~isfield(self.params, 'backpropmissing')
		self.params.backpropmissing = true;
	end
	if ~isfield(self.params, 'useautoencoder')
		self.params.useautoencoder = true;
	end

	assert(self.params.backpropmissing || self.params.useautoencoder, 'You must either backprop missing data or use the autoencoder. Otherwise, nothing is backpropagated.')

	self.w_input = 0;
	self.w_output = 0;
	self.w_missing = 0;
end

% Returns the output of the current neural network for the given input
function [a_output, a_hidden] = feedforward(self, inputs)
	inputs(isnan(inputs)) = 0; % Zero NaN

	% hidden activations
	a_hidden = self.w_input * inputs';

	% output activations
	a_output = self.w_output * a_hidden;
end

function [missing, predictAll] = feedforwardmissing(self, yhat, h, expectedMissing, missingMask)
	numSamples = size(expectedMissing, 1);

	% First initialize our output to the known values; then fill the first column with predictions.
	missing = expectedMissing;
	predictAll = [];
	hiddenPlus = h;

	for i=[1:self.nummissing]
		predictAll = [predictAll; self.w_missing(i, 1:self.params.nh+i-1) * hiddenPlus];

		% Fill the current column with the best prediction if it's NaN; otherwise, use the known value.
		for j = 1:numSamples
			if 0 == missingMask(j, i)
				% fprintf('NaN Filling with %f\n', predictAll(i, j))
				missing(j, i) = predictAll(i, j);
			end
		end

		hiddenPlus = [hiddenPlus; missing(:, i)'];
	end
end

function [nabla_miss] = backpropmissing(self, h, missing, predictAll, expectedMissing)
	nabla_miss = zeros(self.size.w_missing);

	hiddenPlus = [h' missing];
	for i=[1:self.nummissing]
		nabla_miss(i, 1:self.params.nh+i-1) = (predictAll(i, :)' - expectedMissing(:, i))' * hiddenPlus(:, 1:self.params.nh+i-1);
	end
end

% Return a tuple ``(nabla_input, nabla_output)`` representing the gradients for the cost function with respect to self.w_input and self.w_output.
function [nabla_input, nabla_output, nabla_miss] = backprop(self, x, missing, missingMask)
	[yhat, h] = feedforward(self, x);

	if self.params.useautoencoder
		dshare = yhat' - x;
		nabla_output = dshare' * h';
	else
		nabla_output = 0;
	end

	[missingFilled, predictAll] = feedforwardmissing(self, yhat, h, missing, missingMask);
	dshare_missing = predictAll' - missing;

	if self.params.backpropmissing && self.params.useautoencoder
		dshare = [dshare dshare_missing];
		weight_all = [self.w_output; self.w_missing(:, 1:self.params.nh)];
	elseif self.params.useautoencoder
		weight_all = self.w_output;
	elseif self.params.backpropmissing
		dshare = dshare_missing;
		weight_all = self.w_missing(:, 1:self.params.nh);
	end
	nabla_input = (dshare * weight_all)' * x;

	nabla_miss = backpropmissing(self, h, missingFilled, predictAll, missing);

	% If a value was NaN, don't backpropogate it.
	nabla_output(isnan(nabla_output)) = 0;
	nabla_input(isnan(nabla_input)) = 0;
	nabla_miss(isnan(nabla_miss)) = 0;

	% assert(sum(size(nabla_input)==size(self.w_input)) == ndims(nabla_input));
	% assert(sum(size(nabla_output)==size(self.w_output)) == ndims(nabla_output));
	% assert(sum(size(nabla_miss)==size(self.w_missing)) == ndims(nabla_miss));
end

% Learns using the traindata with batch gradient descent.
function [self] = learn(self, Xtrain, missing, missingMask)
	self.numfeatures = size(Xtrain, 2);
	self.numoutputs = size(Xtrain, 2);
	self.numsamples = size(Xtrain, 1);
	self.nummissing = size(missing, 2);
	perturbation = 1;

	self.size = struct();
	self.size.w_output = [self.numoutputs, self.params.nh];
	self.size.w_input = [self.params.nh, self.numfeatures];
	self.size.w_missing = [self.nummissing, self.params.nh+self.nummissing-1];

	self.w_output = normrnd(0.0, perturbation, self.size.w_output);
	self.w_input = normrnd(0.0, perturbation, self.size.w_input);
	self.w_missing = normrnd(0.0, perturbation, self.size.w_missing);
	for i=[1:self.nummissing]
		% Zero the never-used weights. This has no impact on the code.
		self.w_missing(i, self.params.nh+i:self.params.nh+self.nummissing-1) = zeros(1, self.nummissing - i);
	end

	self = learnAdadelta(self, Xtrain, missing, missingMask);
end

% Use the parameters computed in self.learn to give predictions on new observations.
function [missing] = predict(self, Xtest, expectedMissing, missingMask)
	[yhat, h] = feedforward(self, Xtest);
	missing = feedforwardmissing(self, yhat, h, expectedMissing, missingMask);
end

function [self] = learnAdadelta(self, Xtrain, missing, missingMask)
	for i = [1:self.params.epochs]
		% Shuffle indexes
		ind = randperm(self.numsamples);

		exp_nab_out = zeros(self.size.w_output);
		exp_nab_in = zeros(self.size.w_input);
		exp_nab_miss = zeros(self.size.w_missing);
		exp_w_out = zeros(self.size.w_output);
		exp_w_in = zeros(self.size.w_input);
		exp_w_miss = zeros(self.size.w_missing);

		for j_ind = [1:self.numsamples]
			j = ind(j_ind);

			% Compute gradient
			[nabla_input, nabla_output, nabla_miss] = backprop(self, Xtrain(j, :), missing(j, :), missingMask(j, :));

			[exp_nab_in, exp_w_in, delta_w_in] = AdadeltaUpdate(self, exp_nab_in, exp_w_in, nabla_input);
			self.w_input = self.w_input + delta_w_in;

			% No need to update output weights if there isn't an autoencoder; in that case they aren't used.
			if self.params.useautoencoder
				[exp_nab_out, exp_w_out, delta_w_out] = AdadeltaUpdate(self, exp_nab_out, exp_w_out, nabla_output);
				self.w_output = self.w_output + delta_w_out;
			end

			[exp_nab_miss, exp_w_miss, delta_w_miss] = AdadeltaUpdate(self, exp_nab_miss, exp_w_miss, nabla_miss);
			self.w_missing = self.w_missing + delta_w_miss;
		end
	end
end

function [exp_nab, exp_w, delta_w] = AdadeltaUpdate(self, exp_nab, exp_w, nabla)
	% Accumulate gradient
	exp_nab = self.params.rho * exp_nab + (1 - self.params.rho) * nabla.^2;

	% Compute update
	delta_w = - sqrt(exp_w + self.params.epsilon)./sqrt(exp_nab + self.params.epsilon) .* nabla;

	% Accumulate updates
	exp_w = self.params.rho * exp_w + (1 - self.params.rho) * delta_w.^2;
end

% Compute the sigmoid function
function [vecsig] = sigmoid(xvec)
	% Cap -xvec, to avoid overflow
	% Undeflow is okay, since it get set to zero
	xvec(xvec < -100) = -100;
	vecsig = 1.0 ./ (1.0 + exp(-xvec));
end

% Compute the linear function
function [xvec] = linearTrans(xvec)
end
