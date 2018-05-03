% loadMissing551 loads the arm and leg data to do missingness analysis
function [Xtrain, Xtest, Xtest_orig, X, Xall] = loadMissing551(X)
	X = X(randperm(size(X,1)),:); % Shuffle

	% Sort X into train and test sets
	TOTAL_COUNT = size(X, 1);
	TEST_COUNT = 40;
	TRAIN_COUNT = TOTAL_COUNT - TEST_COUNT;
	Xtrain = X(1:TRAIN_COUNT, :);
	Xtest = X(TRAIN_COUNT+1:165, :);
	Xtest_orig = Xtest;

	% Get indices of values to delete
	delHyper = randi(TEST_COUNT, 17, 1);
	delRef2 = randi(TEST_COUNT, 30, 1);
	delRef25 = delRef2(randi(length(delRef2), 6, 1));
	delTEh = randi(TEST_COUNT, 5, 1);

	% Delete values
	Xtest(delHyper, 25) = 0;
	Xtest(delRef2, 29) = 0;
	Xtest(delRef25, 26) = 0;
	Xtest(delTEh, 21) = 0;

	% Create Xall
	Xall = [Xtrain; Xtest];
end