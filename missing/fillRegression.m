% fillRegression uses linear regression on each column with missing data.
% It's using the Matlab default linear regression, which "ignores" NaN values. (I'm not sure what that means.)
function [filledX, covr] = fillRegression(missingX, completeX, mask, originalMissingX, missingMask)
	X = [missingX; completeX];

	filledX = missingX;
	for j = 1:size(missingX, 2)
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		% Create a version of X for this iteration. It needs a column of 1s and should not have the feature we're predicting, so covert that column to ones.
		thisX = X;
		thisX(:, j) = ones(size(X, 1), 1);

		% Calculate weights.
		b = regress(X(:, j), thisX);

		% After prediction, set NaN to zero so that we can multiply some rows to predict missing values.
		thisX(isnan(thisX)) = 0;

		for i = 1:size(missingX, 1)
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, thisX(i, :) * b, originalMissingX(i, j))
				filledX(i, j) = thisX(i, :) * b; % Predict the missing value.
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
