% fillNeural uses a separate neural network on each column with missing data. (Very inefficient!)
function [filledX, covr] = fillNeural(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);

	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			continue
		end

		if ~isfield(arg, 'ones')
			arg.ones = false;
		end
		model.params = arg;

		% Create a version of X for this iteration. It needs a column of 1s and should not have the feature we're predicting, so covert that column to ones.
		thisX = completeX;
		if model.params.ones == true
			thisX(:, j) = ones(size(completeX, 1), 1);
		else
			thisX(:, j) = zeros(size(completeX, 1), 1);
		end

		addpath ./algorithm

		model = neuralnetwork(model);
		model = neuralnetwork(model, thisX, completeX(:, j));

		missX = missingX;
		if model.params.ones == true
			missX(:, j) = ones(numSamplesMissing, 1);
		else
			missX(:, j) = zeros(numSamplesMissing, 1);
		end
		model = neuralnetwork(model, missX);
		missY = model.Y;

		rmpath ./algorithm

		for i = 1:numSamplesMissing
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, missY(i), originalMissingX(i, j))
				filledX(i, j) = missY(i); % Predict the missing value.
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
