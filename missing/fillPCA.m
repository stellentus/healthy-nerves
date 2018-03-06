% fillPCA uses PCA with ALS to fill the values.
function [filledX, covr] = fillPCA(missingX, completeX, mask, originalMissingX, missingMask)
	X = [missingX; completeX];
	[coeff, score, ~, ~, ~, mu] = pca(X, 'VariableWeights', 'variance', 'algorithm', 'als');
	reconstructedX = score * coeff' + repmat(mu, size(X, 1), 1);

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
