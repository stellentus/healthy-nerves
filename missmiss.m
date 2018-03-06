% missmiss loads missing data and does stuff with it
function [missingX, completeX, mask, originalMissingX, missingMask, delayTEd40, TEd40] = missmiss()
	% Load data
	addpath import;
	[armValues, armParticipants] = mefimport(pathFor('arm'), true);
	[legValues, legParticipants] = mefimport(pathFor('leg'), true);

	[armDelayTEd40, armDelayTEh40, ~, ~, armTEd40, armTEh40, ~, ~] = mefTEimport(pathFor('arm'), armParticipants);
	[legDelayTEd40, legDelayTEh40, ~, ~, legTEd40, legTEh40, ~, ~] = mefTEimport(pathFor('leg'), legParticipants);
	clear armParticipants legParticipants;
	rmpath import;

	% Store all samples as X
	X = [armValues; legValues];
	clear armValues legValues;

	delayTEd40 = armDelayTEd40';
	clear armDelayTEd40 legDelayTEd40;
	TEd40 = [armTEd40'; legTEd40'];
	clear armTEd40 legTEd40;

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
