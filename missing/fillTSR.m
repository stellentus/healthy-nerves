% fillTSR uses Trimmed Scores Regression
function [filledX, covr] = fillTSR(missingX, completeX, missingMask, args)
	if ~isfield(args, 'k')
		args.k = 4;
	end

	[filledX, ~, covr] = tsr([missingX; completeX], args.k);
end
