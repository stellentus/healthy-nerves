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

	[missingX, completeX, mask, originalMissingX, missingMask] = deleteProportional(X);
	originalCov = cov([completeX; originalMissingX]);

	funcs = {
		@fillMean,
		@fillCCA,
		@fillPCA,
		@fillRegr,
	};

	for i = 1:length(funcs)
		func = funcs{i};
		[filledX, covr] = func(missingX, completeX, mask, originalMissingX, missingMask);
		err = valueError(missingX, originalMissingX, missingMask, filledX);
		fprintf('The value error for %8s is %f\n', func2str(func), err);
		err = covError(originalCov, covr);
		fprintf('The covar error for %8s is %f\n', func2str(func), err);
	end

	rmpath missing
end
