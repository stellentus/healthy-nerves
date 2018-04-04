% fillNeural uses a separate neural network on each column with missing data. (Very inefficient!)
function [filledX, covr] = fillNeural(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);

	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			continue
		end

		% Create a version of X for this iteration. It needs a column of 1s and should not have the feature we're predicting, so covert that column to ones.
		thisX = completeX;
		thisX(:, j) = ones(size(completeX, 1), 1);

		addpath ./algorithm

		model.name = 'neuralnetwork';
		model = neuralnetwork(model);
		model = neuralnetwork(model, thisX, completeX(:, j));

		missX = missingX;
		missX(:, j) = ones(numSamplesMissing, 1);
		model = neuralnetwork(model, missX);
		missY = model.ytest;

		rmpath ./algorithm

		% After prediction, set NaN to zero so that we can multiply some rows to predict missing values.
		missX(isnan(missX)) = 0;

		for i = 1:numSamplesMissing
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, missY(i), originalMissingX(i, j))
				filledX(i, j) = missY(i); % Predict the missing value.
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
