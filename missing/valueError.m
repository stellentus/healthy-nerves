% valueError compares X values
function [err] = valueError(missingX, originalMissingX, missingMask, filledX)
	mask = ~missingMask;
	err = mean(mean(((originalMissingX - filledX) .* mask) .^ 2));
end
