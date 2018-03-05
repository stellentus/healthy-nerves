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

	filledXMean = fillWithMean(missingX, completeX, mask, originalMissingX, missingMask);
	covrMean = calcCov(completeX, filledXMean);

	err = valueError(missingX, originalMissingX, missingMask, filledXMean);
	disp(err);

	err = covError(originalCov, covrMean);
	disp(err);

	rmpath missing
end
