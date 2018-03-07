% fillMean fills the missing values with the mean for that feature
function [filledX, covr] = fillMean(missingX, completeX, mask, originalMissingX, missingMask, arg)
	mn = nanmean([missingX; completeX]);

	filledX = missingX;
	for j = 1:size(missingX, 2)
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:size(missingX, 1)
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, mn(j), originalMissingX(i, j))
				filledX(i, j) = mn(j);
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
