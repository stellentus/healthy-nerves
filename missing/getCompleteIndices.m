% getCompleteIndices gets a list of the complete indices.
% It can also return the list of indices with missing values and the number of missing values for each of them.
function [completeIndices, missIndices, missCount] = getCompleteIndices(missingX, missingMask)
	[numSamplesMissing, numFeatures] = size(missingX);

	missIndices = [];
	missCount = [];
	completeIndices = [];
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		numColumnPresent = sum(missingMask(:, j));
		if numColumnPresent == numSamplesMissing
			completeIndices = [completeIndices; j];
		else
			missIndices = [missIndices; j];
			missCount = [missCount; numSamplesMissing - numColumnPresent];
		end
	end
end
