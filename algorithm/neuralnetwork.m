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
	if ~isfield(self.params, 'stepsize')
		self.params.stepsize = 1e-5;
	end
	if ~isfield(self.params, 'epochs')
		self.params.epochs = 100;
	end
	if ~isfield(self.params, 'sigmoid')
		self.params.sigmoid = false;
	end

	if self.params.sigmoid
		self.transfer = @sigmoid;
	else
		self.transfer = @linearTrans;
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
	dshare = yhat - y;
	nabla_output = dshare * h';

	numfeatures = size(x, 2);
	numhidden = self.params.nh;
	nabla_input = zeros(numhidden, numfeatures);
	for i = [1:numfeatures] % TODO Optimize by making it not a loop?
		for j = [1:numhidden]
			nabla_input(j, i) = self.w_output(:, j)' * dshare;
			if self.params.sigmoid
				nabla_input(j, i) = nabla_input(j, i) * h(j) * (1 - h(j));
			end
			nabla_input(j, i) = nabla_input(j, i) * x(i);
		end
	end

	% assert(size(nabla_input, 1) == size(self.w_input, 1));
	% assert(size(nabla_input, 2) == size(self.w_input, 2));
	% assert(size(nabla_output, 1) == size(self.w_output, 1));
	% assert(size(nabla_output, 2) == size(self.w_output, 2));
end

% Learns using the traindata with batch gradient descent.
function [self] = learn(self, Xtrain, ytrain)
	numfeatures = size(Xtrain, 2);
	numoutputs = size(ytrain, 2);
	numhidden = self.params.nh;
	perturbation = 1;

	self.w_output = normrnd(0.0, perturbation, [numoutputs, numhidden]);
	self.w_input = normrnd(0.0, perturbation, [numhidden, numfeatures]);

	self = learnStochastic(self, Xtrain, ytrain);
end

% Use the parameters computed in self.learn to give predictions on new observations.
function [ytest] = predict(self, Xtest)
	ytest = feedforward(self, Xtest)';
end

function [self] = learnStochastic(self, Xtrain, ytrain)
	numsamples = size(Xtrain, 1);
	for i = [1:self.params.epochs]
		% Shuffle indexes
		ind = randperm(numsamples);

		for j_ind = [1:numsamples]
			j = ind(j_ind);
			n = self.params.stepsize / (i + 1);

			[nabla_input, nabla_output] = backprop(self, Xtrain(j, :), ytrain(j));

			self.w_input = self.w_input - n * nabla_input;
			self.w_output = self.w_output - n * nabla_output;
		end

		% fprintf('%03i: Cost is %f\n', i, norm(feedforward(self, Xtrain)' - ytrain));
	end
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
