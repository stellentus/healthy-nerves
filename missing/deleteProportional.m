% deleteProportional deletes proportional amounts of missing data
function [X_missing, X_full, mask] = deleteProportional(X)
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

	missingIndices = union(delHyper, union(delRef2, delTEh));
	fullIndices = setxor(missingIndices, [1:TOTAL_COUNT]);

	Xdel = X .* mask;
	X_missing = Xdel(missingIndices, :);
	X_full = X(fullIndices, :);
end