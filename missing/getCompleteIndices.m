% getCompleteIndices gets a list of the complete indices.
% It can also return the list of indices with missing values and the number of missing values for each of them.
function [completeIndices, missIndices, missCount] = getCompleteIndices(missingX, missingMask)
	[numRows, numColumns] = size(missingX);

	missIndices = [];
	missCount = [];
	completeIndices = [];
	for ind = 1:numColumns
		% Skip this column if it has no missing values
		countOfPresentValues = sum(missingMask(:, ind)); % Count the number that aren't mimssing
		if countOfPresentValues == numRows
			completeIndices = [completeIndices; ind];
		else
			missIndices = [missIndices; ind];
			missCount = [missCount; numRows - countOfPresentValues];
		end
	end
end
