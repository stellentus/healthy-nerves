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

	[filledXMean, covrMean] = fillWithMean(missingX, completeX, mask, originalMissingX, missingMask);
	err = valueError(missingX, originalMissingX, missingMask, filledXMean);
	fprintf('The value error for mean filling is %f\n', err);
	err = covError(originalCov, covrMean);
	fprintf('The covariance error for mean filling is %f\n', err);

	[filledXCCA, covrCCA] = fillCCA(missingX, completeX, mask, originalMissingX, missingMask);
	err = valueError(missingX, originalMissingX, missingMask, filledXCCA);
	fprintf('The value error for CCA is %f\n', err);
	err = covError(originalCov, covrCCA);
	fprintf('The covariance error for CCA is %f\n', err);

	rmpath missing
end
