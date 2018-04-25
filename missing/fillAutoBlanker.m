% fillAutoBlanker uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoBlanker(missingX, completeX, missingMask, arg)
	if ~isfield(args, 'handleNaN')
		ars.handleNaN = 'mean';
	end

	missingX = fillNaive(missingX, completeX, missingMask, args);
	allX = [completeX; missingX];

	addpath ./algorithm

	% Train
	model.params = arg;
	model = neuralnetwork(model);
	model = neuralnetwork(model, allX, allX);

	% Predict
	model = neuralnetwork(model, missingX);
	filledX = model.Y;

	rmpath ./algorithm
end
