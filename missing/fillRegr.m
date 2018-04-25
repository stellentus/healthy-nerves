% fillRegr uses linear regression on each column with missing data.
% It's using the Matlab default linear regression, which "ignores" NaN values. (I'm not sure what that means.)
function [filledX] = fillRegr(missingX, completeX, missingMask, arg)
	% If the appropriate flag is set, this function will fill NaN with some naive value before doing PCA. Otherwise, it does nothing.
	missingX = fillNaive(missingX, completeX, missingMask, arg);

	X = [missingX; completeX];

	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			continue
		end

		% Create a version of X for this iteration. It needs a column of 1s and should not have the feature we're predicting, so covert that column to ones.
		thisX = X;
		thisX(:, j) = ones(size(X, 1), 1);

		% Calculate weights.
		b = regress(X(:, j), thisX);

		% After prediction, set NaN to zero so that we can multiply some rows to predict missing values.
		thisX(isnan(thisX)) = 0;

		filledX(:, j) = thisX(1:size(missingX, 1), :) * b; % Predict the missing value.
	end
end
