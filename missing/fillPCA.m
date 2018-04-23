% fillPCA uses PCA with ALS to fill the values.
%   filledX is the best-guess filling of the missing values (with known values used when possible).
function [filledX] = fillPCA(missingX, completeX, mask, originalMissingX, missingMask, args)
	if ~isfield(args, 'k')
		args.k = 4;
	end
	if ~isfield(args, 'VariableWeights')
		args.VariableWeights = ones(1, size(missingX, 2));
	end

	% The following three arguments provide different ways to initialize the NaN values. It doesn't make sense to set more than one of them.
	% The all perform about the same, with no significant difference between zeroNaN and randomNaN. meanNaN is barely worse.
	if isfield(args, 'zeroNaN') && args.zeroNaN
		missingX(isnan(missingX)) = 0;
	end
	if isfield(args, 'meanNaN') && args.meanNaN
		meanX = ones(size(missingX, 2), 1)*nanmean([missingX; completeX]);
		missingX(isnan(missingX)) = meanX(isnan(missingX));
	end
	if isfield(args, 'randomNaN') && args.randomNaN
		randX = rand(size(missingX));
		missingX(isnan(missingX)) = randX(isnan(missingX));
	end

	X = [missingX; completeX];
	[coeff, score, ~, ~, ~, mu] = pca(X, 'VariableWeights', args.VariableWeights, 'algorithm', 'als');
	coeff = coeff';
	filledX = score(:, 1:args.k) * coeff(1:args.k, :) + repmat(mu, size(X, 1), 1);
end
