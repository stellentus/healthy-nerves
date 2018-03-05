% valueError compares X values
function [err] = valueError(missingX, originalMissingX, missingMask, filledX)
	err = 0;
	count = 0;
	for j = 1:size(missingX, 2)
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:size(missingX, 1)
			if isnan(missingX(i, j))
				difference = originalMissingX(i, j) - filledX(i, j);
				err = err + (difference ^ 2);
				count = count + 1;
			end
		end
	end

	err = err / count;
end
