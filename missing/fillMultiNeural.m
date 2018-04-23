% fillMultiNeural uses a separate neural network on each column with missing data. (Very inefficient!)
function [filledX] = fillMultiNeural(missingX, completeX, mask, originalMissingX, missingMask, arg)
	[numSamplesMissing, numFeatures] = size(missingX);

	if ~isfield(arg, 'ones')
		arg.ones = false;
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

	inputs = completeX(:, completeIndices);
	outputs = completeX(:, missIndices);

	addpath ./algorithm

	% Train
	model = neuralnetwork(model);
	model = neuralnetwork(model, inputs, outputs);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	missY = model.Y;

	rmpath ./algorithm

	filledX = missingX;
	filledX(:, missIndices) = missY(:, 1:length(missIndices)); % Predict the missing value.
end
