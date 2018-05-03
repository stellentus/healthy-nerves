% updateKnownValues returns missingX with predictedX imputed wherever missingMask is 0.
% The optional originalMissingX argument can be included to print debug.
function [missingX] = updateKnownValues(predictedX, missingX, missingMask, originalMissingX)
	printDebug = (nargin == 4);

	[numSamplesMissing, numFeatures] = size(missingX);
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			continue
		end

		for i = 1:numSamplesMissing
			if 0 == missingMask(i, j)
				if printDebug
					fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, predictedX(i, j), originalMissingX(i, j))
				end

				missingX(i, j) = predictedX(i, j);
			end
		end
	end
end
