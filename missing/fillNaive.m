% fillNaive uses one of three naive strategies.
% The three arguments provide different ways to initialize the NaN values. It doesn't make sense to set more than one of them.
function [missingX] = fillNaive(missingX, completeX, missingMask, args)
	mask = isnan(missingX);
	if isfield(args, 'useMissingMaskForNaNFill') && args.useMissingMaskForNaNFill
		mask = ~missingMask;
	end

	if isfield(args, 'handleNaN')
		switch args.handleNaN
			case 'zero'
				missingX(mask) = 0;
			case 'mean'
				meanX = ones(size(missingX, 1), 1)*nanmean([missingX; completeX]);
				missingX(mask) = meanX(mask);
			case 'random'
				randX = rand(size(missingX));
				missingX(mask) = randX(mask);
		end
	end
end
