% fillAutosplitcoder uses an autoencoder (but with a few branches in the logic).
function [filledX, covr] = fillAutosplitcoder(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);

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

	trainData = [completeX; missingX]; % all data

	addpath ./algorithm

	% Train
	model = neuralnetwork(model);
	model = neuralnetwork(model, trainData(:, completeIndices), trainData);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	missY = model.Y;

	rmpath ./algorithm

	for j_ind = 1:length(missIndices)
		j = missIndices(j_ind);
		for i = 1:numSamplesMissing
			if isnan(filledX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, missY(i, j), originalMissingX(i, j))
				filledX(i, j) = missY(i, j); % Predict the missing value.
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
