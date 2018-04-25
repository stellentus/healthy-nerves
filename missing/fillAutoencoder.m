% fillAutoencoder uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoencoder(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'trainMissingRows')
		arg.trainMissingRows = false;
	end

	completeIndices = getCompleteIndices(missingX, missingMask);

	if arg.trainMissingRows
		% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
		missingX = fillNaive(missingX, completeX, missingMask, arg);
		trainData = [completeX; missingX]; % all data
	else
		trainData = completeX;             % complete data
	end

	addpath ./algorithm

	% Train
	model.params = arg;
	model = neuralnetwork(model);
	model = neuralnetwork(model, trainData(:, completeIndices), trainData);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	filledX = model.Y;

	rmpath ./algorithm
end
