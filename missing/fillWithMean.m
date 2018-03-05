% fillWithMean fills the missing values with the mean for that feature
function [filledX] = fillWithMean(missingX, completeX, mask, originalMissingX, missingMask)
	mn = nanmean([missingX; completeX]);

	filledX = missingX;
	for j = 1:size(missingX, 2)
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:size(missingX, 1)
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f\n', i, j, mn(j))
				filledX(i, j) = mn(j);
			end
		end
	end
end
