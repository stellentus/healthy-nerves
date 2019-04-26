% fillDA uses Data Augmentation.
function [filledX, covr] = fillDA(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'number')
		arg.number = 10;
	end
	if ~isfield(arg, 'length')
		arg.length = 100;
	end

	[~, ~, ~, covr, filledX] = da([missingX; completeX], arg.number, arg.length);
end
