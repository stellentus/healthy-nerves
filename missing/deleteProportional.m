% deleteProportional deletes proportional amounts of missing data
function [missingX, completeX, mask, sortedAllX, sortedMask, count] = deleteProportional(X, target)
	numMissing = 0;
	count = 0;
	while (numMissing == 0) || (nargin == 2 && numMissing ~= target) % At least once, but keep going if not on target
		[missingX, completeX, mask, sortedAllX, sortedMask] = delete(X);
		numMissing = size(missingX, 1);
		count = count + 1;
	end
	% Could print the number of iterations here
end

function [missingX, completeX, mask, sortedAllX, sortedMask] = delete(X)
	TOTAL_COUNT = size(X, 1);

	% Get indices of values to delete
	delHyper = randi(TOTAL_COUNT, round(.056*TOTAL_COUNT), 1);
	delRef2 = randi(TOTAL_COUNT, round(.096*TOTAL_COUNT), 1);
	delRef25 = delRef2(randi(length(delRef2), round(.02/.096*TOTAL_COUNT), 1));
	delTEh = randi(TOTAL_COUNT, round(.015*TOTAL_COUNT), 1);

	% Create mask
	mask = ones(size(X));
	mask(delHyper, 25) = 0;
	mask(delRef2, 29) = 0;
	mask(delRef25, 26) = 0;
	mask(delTEh, 21) = 0;

	% Create NaN mask
	maskNaN = mask;
	maskNaN(mask == 0) = NaN;

	missingIndices = union(delHyper, union(delRef2, delTEh));
	completeIndices = setxor(missingIndices, [1:TOTAL_COUNT]);

	Xdel = X .* maskNaN;
	missingX = Xdel(missingIndices, :);
	completeX = X(completeIndices, :);

	sortedAllX = X([completeIndices; missingIndices], :);
	sortedMask = mask([completeIndices; missingIndices], :);
end

