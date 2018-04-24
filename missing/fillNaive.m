% fillNaive uses one of three naive strategies.
% The three arguments provide different ways to initialize the NaN values. It doesn't make sense to set more than one of them.
function [missingX] = fillNaive(missingX, completeX, missingMask, args)
	if isfield(args, 'zeroNaN') && args.zeroNaN
		missingX(isnan(missingX)) = 0;
	end
	if isfield(args, 'meanNaN') && args.meanNaN
		meanX = ones(size(missingX, 1), 1)*nanmean([missingX; completeX]);
		missingX(isnan(missingX)) = meanX(isnan(missingX));
	end
	if isfield(args, 'randomNaN') && args.randomNaN
		randX = rand(size(missingX));
		missingX(isnan(missingX)) = randX(isnan(missingX));
	end
end
