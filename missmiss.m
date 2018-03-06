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
		@fillPCA,
		@fillCCA,
		@fillMean,
		@fillRegr,
		@fillMI,
	};

	fprintf(' Algorithm | Value Error | Covariance Error\n');
	fprintf('-----------+-------------+------------------\n');

	for i = 1:length(funcs)
		func = funcs{i};
		[filledX, covr] = func(missingX, completeX, mask, originalMissingX, missingMask);
		verr = valueError(missingX, originalMissingX, missingMask, filledX);
		cerr = covError(originalCov, covr);
		fprintf('%10s | %9s   | %9s\n', func2str(func), num2str(verr, '%.2f'), num2str(cerr, '%.2f'));
	end

	rmpath missing
end
