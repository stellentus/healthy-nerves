% neuralnetwork does a whole bunch of stuff related to a neural network.
% If no additional arguments are provided, it initializes and resets.
% If two additional arguments are provided, they are used as Xtrain and ytrain.
% If one additional argument is provided, it's used as Xtest.
function [self] = neuralnetwork(self, X, ytrain)
	switch nargin
		case 1
			self = reset(self);
		case 3 % Xtrain, ytrain
			self = learn(self, X, ytrain);
		case 2 % Xtest
			self.Y = predict(self, X);
		otherwise
			disp('Error in number of arguments to Neural Network.')
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
	if ~isfield(self.params, 'sigmoid')
		self.params.sigmoid = false;
	end
	if ~isfield(self.params, 'rho')
		self.params.rho = 0.99; % .997 performs slightly better, but .999 is much worse
	end
	if ~isfield(self.params, 'useSGD')
		self.params.useSGD = false;
	end

	if self.params.sigmoid
		self.transfer = @sigmoid;
	else
		self.transfer = @linearTrans;
	end

	if self.params.useSGD
		self.learnAlg = @learnSGD;
	else
		self.learnAlg = @learnAdadelta;
	end

	self.w_input = 0;
	self.w_output = 0;
end

% Returns the output of the current neural network for the given input
function [a_output, a_hidden] = feedforward(self, inputs)
	inputs(isnan(inputs)) = 0; % Zero NaN

	% hidden activations
	a_hidden = self.transfer(self.w_input * inputs');

	% output activations
	a_output = self.transfer(self.w_output * a_hidden);
end

% Return a tuple ``(nabla_input, nabla_output)`` representing the gradients for the cost function with respect to self.w_input and self.w_output.
function [nabla_input, nabla_output] = backprop(self, x, y)
	[yhat, h] = feedforward(self, x);
	dshare = yhat' - y;
	nabla_output = dshare' * h';

	sigmoidTerm = ones(1, self.params.nh);
	if self.params.sigmoid
		sigmoidTerm = (h .* (1 - h))';
	end

	nabla_input = (dshare * self.w_output .* sigmoidTerm)' * x;

	% If a value was NaN, don't backpropogate it.
	nabla_output(isnan(nabla_output)) = 0;
	nabla_input(isnan(nabla_input)) = 0;

	% assert(sum(size(nabla_input)==size(self.w_input)) == ndims(nabla_input));
	% assert(sum(size(nabla_output)==size(self.w_output)) == ndims(nabla_output));
end

% Learns using the traindata with batch gradient descent.
function [self] = learn(self, Xtrain, ytrain)
	self.numfeatures = size(Xtrain, 2);
	self.numoutputs = size(ytrain, 2);
	self.numsamples = size(Xtrain, 1);
	perturbation = 1;

	self.w_output = normrnd(0.0, perturbation, [self.numoutputs, self.params.nh]);
	self.w_input = normrnd(0.0, perturbation, [self.params.nh, self.numfeatures]);

	% fprintf('\n000: Cost is %f\n', norm(feedforward(self, Xtrain)' - ytrain));
	self = self.learnAlg(self, Xtrain, ytrain);
end

% Use the parameters computed in self.learn to give predictions on new observations.
function [ytest] = predict(self, Xtest)
	ytest = feedforward(self, Xtest)';
end

function [self] = learnSGD(self, Xtrain, ytrain)
	for i = [1:self.params.epochs]
		% Shuffle indexes
		ind = randperm(self.numsamples);

		for j_ind = [1:self.numsamples]
			j = ind(j_ind);

			[nabla_input, nabla_output] = backprop(self, Xtrain(j, :), ytrain(j, :));

			self.w_input = self.w_input - n * nabla_input;
			self.w_output = self.w_output - n * nabla_output;
		end

		% fprintf('%03i: Cost is %f\n', i, norm(feedforward(self, Xtrain)' - ytrain));
	end
end

function [self] = learnAdadelta(self, Xtrain, ytrain)
	for i = [1:self.params.epochs]
		% Shuffle indexes
		ind = randperm(self.numsamples);
		n = self.params.epsilon / (i + 1);

		exp_nab_out = zeros(self.numoutputs, self.params.nh);
		exp_nab_in = zeros(self.params.nh, self.numfeatures);
		exp_w_out = zeros(self.numoutputs, self.params.nh);
		exp_w_in = zeros(self.params.nh, self.numfeatures);

		for j_ind = [1:self.numsamples]
			j = ind(j_ind);

			% Compute gradient
			[nabla_input, nabla_output] = backprop(self, Xtrain(j, :), ytrain(j, :));

			[exp_nab_in, exp_w_in, delta_w_input] = AdadeltaUpdate(self, exp_nab_in, exp_w_in, nabla_input);
			self.w_input = self.w_input + delta_w_input;

			[exp_nab_out, exp_w_out, delta_w_output] = AdadeltaUpdate(self, exp_nab_out, exp_w_out, nabla_output);
			self.w_output = self.w_output + delta_w_output;
		end

		% fprintf('%03i: Cost is %f\n', i, norm(feedforward(self, Xtrain)' - ytrain));
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
