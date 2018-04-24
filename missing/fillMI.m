% fillMI uses multiple imputation.
% It's using some MI code I got online. I don't understand the code. :/
function [filledX, covr] = fillMI(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'number')
		arg.number = 10;
	end
	if ~isfield(arg, 'length')
		arg.length = 100;
	end

	[~, ~, ~, covr, filledX] = mi([missingX; completeX], arg.number, arg.length);
end
