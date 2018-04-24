% fillAutoIter uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoIter(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'epochs')
		arg.epochs = 100;
	end
	model.params = arg;

	% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
	missingX = fillNaive(missingX, completeX, missingMask, arg);

	addpath ./algorithm

	model = neuralnetwork(model); % Set weights back to random

	filledX = missingX;
	for i=1:arg.epochs
		trainData = [completeX; filledX]; % all data
		model = neuralnetwork(model, trainData, trainData); % Train

		model = neuralnetwork(model, filledX); % Predict
		filledX = model.Y;
	end

	rmpath ./algorithm
end
