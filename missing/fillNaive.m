% fillNaive uses one of three naive strategies.
% The three arguments provide different ways to initialize the NaN values. It doesn't make sense to set more than one of them.
function [missingX] = fillNaive(missingX, completeX, missingMask, args)
	mask = isnan(missingX);
	if isfield(args, 'useMissingMask') && args.useMissingMask
		mask = ~missingMask;
	end

	if isfield(args, 'zeroNaN') && args.zeroNaN
		missingX(mask) = 0;
	end
	if isfield(args, 'meanNaN') && args.meanNaN
		meanX = ones(size(missingX, 1), 1)*nanmean([missingX; completeX]);
		missingX(mask) = meanX(mask);
	end
	if isfield(args, 'randomNaN') && args.randomNaN
		randX = rand(size(missingX));
		missingX(mask) = randX(mask);
	end
end
