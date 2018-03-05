% cmput551 does the CMPUT 551 preliminary analysis.
function cmput551()
	% Load data
	addpath import;
	armValues = mefimport(pathFor('arm'), true);
	legValues = mefimport(pathFor('leg'), true);
	rmpath import;

	% Store all samples as X
	X = [armValues; legValues];
	clear armValues legValues;

	addpath missing
	[Xtrain, Xtest, Xtest_orig, X, Xall] = loadMissing(X);
	plot551(Xtrain, Xtest, Xtest_orig, X, Xall);
	rmpath missing
end
