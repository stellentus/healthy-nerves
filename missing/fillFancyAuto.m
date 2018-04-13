% fillFancyAuto uses an autoencoder and deals with missing data in a fancy way. Yep, that's really specific.
function [filledX, covr] = fillFancyAuto(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);

	model.params = arg;

	missIndices = [];
	missCount = [];
	completeIndices = [];
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		numColumnPresent = sum(missingMask(:, j));
		if numColumnPresent == numSamplesMissing
			completeIndices = [completeIndices; j];
		else
			missIndices = [missIndices; j];
			missCount = [missCount; numSamplesMissing - numColumnPresent];
		end
	end

	% Sort the missing values by frequency.
	[~, idx] = sort(missCount);
	missIndices = missIndices(idx);

	trainData = [completeX; missingX];

	% Train
	model = reset(model);
	model = learn(model, trainData(:, completeIndices), trainData(:, missIndices));

	% Predict
	missY = predict(model, missingX(:, completeIndices), missingX(:, missIndices));

	for j_ind = 1:length(missIndices)
		j = missIndices(j_ind);
		for i = 1:numSamplesMissing
			if isnan(filledX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, missY(i, j_ind), originalMissingX(i, j))
				filledX(i, j) = missY(i, j_ind); % Predict the missing value.
			end
		end
	end

	covr = calcCov(completeX, filledX);
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

function [missing, nabla_miss] = frontBackMissing(self, yhat, h, expectedMissing)
	numSamples = size(expectedMissing, 1);
	nabla_miss = zeros(self.size.w_missing);

	% First initialize our output to the known values; then fill the first column with predictions.
	missing = expectedMissing;
	for j = 1:numSamples
		if isnan(missing(j, 1))
			% fprintf('NaN Filling with %f\n', yhat(self.numoutputs, j))
			missing(j, 1) = yhat(self.numoutputs, j);
		end
	end

	for i=[1:self.nummissing]
		% TODO feed in the correct values when possible
		hiddenPlus = [h; missing(:, 1:i)'];
		thisMiss = self.w_missing(i, 1:self.params.nh+i) * hiddenPlus;
		nabla_miss(i, 1:self.params.nh+i) = (thisMiss' - expectedMissing(:, i))' * hiddenPlus';

		% Fill the current column with the best prediction if it's NaN; otherwise, use the known value.
		for j = 1:numSamples
			if isnan(missing(j, i+1))
				% fprintf('NaN Filling with %f\n', thisMiss(j))
				missing(j, i+1) = thisMiss(j);
			end
		end
	end

	nabla_miss(isnan(nabla_miss)) = 0;

	assert(sum(size(nabla_miss)==size(self.w_missing)) == ndims(nabla_miss));
end

% Return a tuple ``(nabla_input, nabla_output)`` representing the gradients for the cost function with respect to self.w_input and self.w_output.
function [nabla_input, nabla_output, nabla_miss] = backprop(self, x, missing)
	[yhat, h] = feedforward(self, x);
	dshare = yhat' - x;
	nabla_output = dshare' * h';

	nabla_input = (dshare * self.w_output)' * x;

	% If a value was NaN, don't backpropogate it.
	nabla_output(isnan(nabla_output)) = 0;
	nabla_input(isnan(nabla_input)) = 0;

	% assert(sum(size(nabla_input)==size(self.w_input)) == ndims(nabla_input));
	% assert(sum(size(nabla_output)==size(self.w_output)) == ndims(nabla_output));

	% Next backpropogate missing values
	[~, nabla_miss] = frontBackMissing(self, yhat, h, missing);
end

% Learns using the traindata with batch gradient descent.
function [self] = learn(self, Xtrain, missing)
	self.numfeatures = size(Xtrain, 2);
	self.numoutputs = size(Xtrain+1, 2); % Add the first missing column to output
	self.numsamples = size(Xtrain, 1);
	self.nummissing = size(missing, 2)-1; % Minus one because self.numoutputs contains one of them.
	perturbation = 1;

	self.size = struct();
	self.size.w_output = [self.numoutputs, self.params.nh];
	self.size.w_input = [self.params.nh, self.numfeatures];
	self.size.w_missing = [self.nummissing, self.params.nh+self.nummissing];

	self.w_output = normrnd(0.0, perturbation, self.size.w_output);
	self.w_input = normrnd(0.0, perturbation, self.size.w_input);
	self.w_missing = normrnd(0.0, perturbation, self.size.w_missing);

	self = learnAdadelta(self, Xtrain, missing);
end

% Use the parameters computed in self.learn to give predictions on new observations.
function [missing] = predict(self, Xtest, missing)
	[yhat, h] = feedforward(self, Xtest);
	missing = frontBackMissing(self, yhat, h, missing);
end

function [self] = learnAdadelta(self, Xtrain, missing)
	for i = [1:self.params.epochs]
		% Shuffle indexes
		ind = randperm(self.numsamples);
		n = self.params.epsilon / (i + 1);

		exp_nab_out = zeros(self.size.w_output);
		exp_nab_in = zeros(self.size.w_input);
		exp_nab_miss = zeros(self.size.w_missing);
		exp_w_out = zeros(self.size.w_output);
		exp_w_in = zeros(self.size.w_input);
		exp_w_miss = zeros(self.size.w_missing);

		for j_ind = [1:self.numsamples]
			j = ind(j_ind);

			% Compute gradient
			[nabla_input, nabla_output, nabla_miss] = backprop(self, Xtrain(j, :), missing(j, :));

			[exp_nab_in, exp_w_in, delta_w_in] = AdadeltaUpdate(self, exp_nab_in, exp_w_in, nabla_input);
			self.w_input = self.w_input + delta_w_in;

			[exp_nab_out, exp_w_out, delta_w_out] = AdadeltaUpdate(self, exp_nab_out, exp_w_out, nabla_output);
			self.w_output = self.w_output + delta_w_out;

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
