% fillMean fills the missing values with the mean for that feature
function [filledX] = fillMean(missingX, completeX, mask, originalMissingX, missingMask, arg)
	arg.meanNaN = true; % Ensure mean-filling is enabled
	filledX = fillNaive(missingX, completeX, mask, originalMissingX, missingMask, arg);
end
