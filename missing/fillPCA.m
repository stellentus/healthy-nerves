% fillPCA uses PCA with ALS to fill the values.
%   filledX is the best-guess filling of the missing values (with known values used when possible).
function [filledX] = fillPCA(missingX, completeX, missingMask, args)
	if ~isfield(args, 'k')
		args.k = 4;
	end
	if ~isfield(args, 'VariableWeights')
		args.VariableWeights = ones(1, size(missingX, 2));
	end

	% If the appropriate flag is set, this function will fill NaN with some naive value before doing PCA. Otherwise, it does nothing.
	missingX = fillNaive(missingX, completeX, missingMask, args);

	X = [missingX; completeX];
	[coeff, score, ~, ~, ~, mu] = pca(X, 'VariableWeights', args.VariableWeights, 'algorithm', 'als');
	coeff = coeff';
	filledX = score(:, 1:args.k) * coeff(1:args.k, :) + repmat(mu, size(X, 1), 1);
end
