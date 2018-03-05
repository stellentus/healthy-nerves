% deleteProportional deletes proportional amounts of missing data
function [X_missing, X_full, X] = deleteProportional(X)
	X = X(randperm(size(X,1)),:); % Shuffle

	% Sort X into train and test sets
	TOTAL_COUNT = size(X, 1);

	% Get indices of values to delete
	delHyper = randi(TOTAL_COUNT, round(.056*TOTAL_COUNT), 1);
	delRef2 = randi(TOTAL_COUNT, round(.096*TOTAL_COUNT), 1);
	delRef25 = delRef2(randi(length(delRef2), round(.02/.096*TOTAL_COUNT), 1));
	delTEh = randi(TOTAL_COUNT, round(.015*TOTAL_COUNT), 1);

	% Delete values
	X(delHyper, 25) = 0;
	X(delRef2, 29) = 0;
	X(delRef25, 26) = 0;
	X(delTEh, 21) = 0;

	missingIndices = union(delHyper, union(delRef2, delTEh));
	fullIndices = setxor(missingIndices, [1:TOTAL_COUNT]);

	X_missing = X(missingIndices);
	X_full = X(fullIndices);

	X = X([fullIndices; missingIndices]);
end