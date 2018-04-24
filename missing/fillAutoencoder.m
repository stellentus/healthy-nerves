% fillAutoencoder uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoencoder(missingX, completeX, mask, originalMissingX, missingMask, arg)
	[numSamplesMissing, numFeatures] = size(missingX);

	if ~isfield(arg, 'useAll')
		arg.useAll = false;
	end
	model.params = arg;

	missIndices = [];
	completeIndices = [];
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			completeIndices = [completeIndices; j];
		else
			missIndices = [missIndices; j];
		end
	end

	if arg.useAll
		% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
		missingX = fillNaive(missingX, completeX, mask, originalMissingX, missingMask, arg);
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
