% fillMI uses multiple imputation.
% It's using some MI code I got online. I don't understand the code. :/
function [filledX, covr] = fillMI(missingX, completeX, mask, originalMissingX, missingMask, arg)
	if ~isfield(arg, 'number')
		arg.number = 10;
	end
	if ~isfield(arg, 'length')
		arg.length = 100;
	end

	[~, ~, ~, covr, Y] = mi([missingX; completeX], arg.number, arg.length);

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
