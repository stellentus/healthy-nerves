% fillPCA uses PCA with ALS to fill the values.
%   filledX is the best-guess filling of the missing values (with known values used when possible).
function [filledX, covr] = fillPCA(missingX, completeX, mask, originalMissingX, missingMask, args)
	if ~isfield(args, 'k')
		args.k = 4;
	end
	if ~isfield(args, 'VariableWeights')
		args.VariableWeights = ones(1, size(missingX, 2));
	end

	X = [missingX; completeX];
	[coeff, score, ~, ~, ~, mu] = pca(X, 'VariableWeights', args.VariableWeights, 'algorithm', 'als');
	coeff = coeff';
	reconstructedX = score(:, 1:args.k) * coeff(1:args.k, :) + repmat(mu, size(X, 1), 1);

	filledX = missingX;
	for j = 1:size(missingX, 2)
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:size(missingX, 1)
			if isnan(missingX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, reconstructedX(i, j), originalMissingX(i, j))
				filledX(i, j) = reconstructedX(i, j);
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
