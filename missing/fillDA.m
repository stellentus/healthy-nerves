% fillDA uses Data Augmentation.
function [filledX, covr] = fillDA(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'number')
		arg.number = 10;
	end
	if ~isfield(arg, 'length')
		arg.length = 100;
	end
	if ~isfield(arg, 'zmuv')
		arg.zmuv = false;
	end

	X = [missingX; completeX];

	if arg.zmuv
		mn = mean(X, 'omitnan');
		st = std(X, 'omitnan');
		X = (X - mn) ./ st;
	end

	[~, ~, ~, covr, filledX] = da([missingX; completeX], arg.number, arg.length);

	if arg.zmuv
		filledX = (filledX .* st) + mn;
		covr = covr.*st.*st';
	end
end
