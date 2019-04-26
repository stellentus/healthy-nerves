% fillTSR uses Trimmed Scores Regression
function [filledX, covr] = fillTSR(missingX, completeX, missingMask, args)
	if ~isfield(args, 'k')
		args.k = 4;
	end
	if ~isfield(args, 'conv')
		args.conv = 1e-10;
	end
	if ~isfield(args, 'zmuv')
		args.zmuv = false;
	end

	X = [missingX; completeX];

	if args.zmuv
		mn = mean(X, 'omitnan');
		st = std(X, 'omitnan');
		X = (X - mn) ./ st;
	end

	[filledX, ~, covr] = tsr(X, args.k);

	if args.zmuv
		filledX = (filledX .* st) + mn;
		covr = covr.*st.*st';
	end
end
