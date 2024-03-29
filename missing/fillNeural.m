% fillNeural uses a separate neural network on each column with missing data. (Very inefficient!)
function [filledX] = fillNeural(missingX, completeX, missingMask, arg)
	filledX = missingX; % Make it the right size
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

		filledX(:, j) = missY(:); % Predict the missing value.
	end
end
