% getCompleteIndices gets a list of the complete indices.
% It can also return the list of indices with missing values and the number of missing values for each of them.
% By default it operates on columns, but the third argument can be used to change that.
function [completeIndices, missIndices, missCount] = getCompleteIndices(missingX, missingMask, dim)
	if nargin < 3
		dim = 2
	end

	[numRows, numColumns] = size(missingX);

	if dim == 1
		numToIterate = numRows;
		maxCount = numColumns;
	else
		numToIterate = numColumns;
		maxCount = numRows;
	end

	missIndices = [];
	missCount = [];
	completeIndices = [];
	for ind = 1:numToIterate
		% Skip this column if it has no missing values
		if dim == 1
			countOfPresentValues = sum(missingMask(ind, :)); % Count the number that aren't missing
		else
			countOfPresentValues = sum(missingMask(:, ind)); % Count the number that aren't missing
		end

		if countOfPresentValues == maxCount
			completeIndices = [completeIndices; ind];
		else
			missIndices = [missIndices; ind];
			missCount = [missCount; maxCount - countOfPresentValues];
		end
	end
end
