% valueError compares X values
function [err] = valueError(missingX, originalMissingX, missingMask, filledX)
	mask = ~missingMask;
	err = sum(sum(((originalMissingX - filledX) .* mask) .^ 2)) / sum(sum(mask));
end
