% fillMean fills the missing values with the mean for that feature
function [filledX] = fillMean(missingX, completeX, mask, originalMissingX, missingMask, arg)
	mn = nanmean([missingX; completeX]);

	filledX = missingX;
	for j = 1:size(missingX, 2)
		for i = 1:size(missingX, 1)
			filledX(i, j) = mn(j);
		end
	end
end
