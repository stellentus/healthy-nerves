% missmiss loads missing data and does stuff with it
function [missingX, completeX, mask, originalMissingX, missingMask] = missmiss()
	% Load data
	addpath import;
	armValues = mefimport(pathFor('arm'), true);
	legValues = mefimport(pathFor('leg'), true);
	rmpath import;

	% Store all samples as X
	X = [armValues; legValues];
	clear armValues legValues;

	addpath missing

	[missingX, completeX, mask, originalMissingX, missingMask] = deleteProportional(X, 25);
	originalCov = cov([completeX; originalMissingX]);

	funcs = {
		@fillWithMean,
		@fillCCA,
		@fillPCA,
		@fillRegression,
	};

	for i = 1:length(funcs)
		func = funcs{i};
		[filledX, covr] = func(missingX, completeX, mask, originalMissingX, missingMask);
		err = valueError(missingX, originalMissingX, missingMask, filledX);
		fprintf('The value error for %s is %f\n', func2str(func), err);
		err = covError(originalCov, covr);
		fprintf('The covariance error for %s is %f\n', func2str(func), err);
	end

	rmpath missing
end
