% fillMean fills the missing values with the mean for that feature
function [filledX] = fillMean(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = ones(size(missingX, 2), 1)*nanmean([missingX; completeX]);
end
