% deleteProportional deletes proportional amounts of missing data
function [X_missing, X_full, mask, count] = deleteProportional(X, target)
	numMissing = 0;
	count = 0;
	while (numMissing == 0) || (nargin == 2 && numMissing ~= target) % At least once, but keep going if not on target
		[X_missing, X_full, mask] = delete(X);
		numMissing = size(X_missing, 1);
		count = count + 1;
	end
	% Could print the number of iterations here
end

function [X_missing, X_full, mask] = delete(X)
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
	fullIndices = setxor(missingIndices, [1:TOTAL_COUNT]);

	Xdel = X .* maskNaN;
	X_missing = Xdel(missingIndices, :);
	X_full = X(fullIndices, :);
end

