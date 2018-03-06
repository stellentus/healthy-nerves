% fillMultI uses multiple imputation.
% It's using some MI code I got online. I don't understand the code. :/
function [filledX, covr] = fillMultI(missingX, completeX, mask, originalMissingX, missingMask)
	[~, ~, ~, covr, Y] = mi([missingX; completeX], 10, 100);

	filledX = missingX;
	for j = 1:size(missingX, 2)
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:size(missingX, 1)
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, Y(i, j), originalMissingX(i, j))
				filledX(i, j) = Y(i, j);
			end
		end
	end
end
