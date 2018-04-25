% fillAutoencoder uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoencoder(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'useAll')
		arg.useAll = false;
	end
	model.params = arg;

	completeIndices = getCompleteIndices(missingX, missingMask);

	if arg.useAll
		% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
		missingX = fillNaive(missingX, completeX, missingMask, arg);
		trainData = [completeX; missingX]; % all data
	else
		trainData = completeX;             % complete data
	end

	addpath ./algorithm

	% Train
	model = neuralnetwork(model);
	model = neuralnetwork(model, trainData(:, completeIndices), trainData);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	filledX = model.Y;

	rmpath ./algorithm
end
