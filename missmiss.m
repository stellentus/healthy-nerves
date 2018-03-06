% missmiss loads missing data and does stuff with it
function [missingX, completeX, mask, originalMissingX, missingMask, delayTEd40, TEd40] = missmiss()
	X = loadMEF();

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

function [X] = loadMEF()
	addpath import;
	[armValues, armParticipants] = mefimport(pathFor('arm'), true);
	[legValues, legParticipants] = mefimport(pathFor('leg'), true);

	[armDelayTEd40, armDelayTEh40, ~, ~, armTEd40, armTEh40, ~, ~] = mefTEimport(pathFor('arm'), armParticipants);
	[legDelayTEd40, legDelayTEh40, ~, ~, legTEd40, legTEh40, ~, ~] = mefTEimport(pathFor('leg'), legParticipants);
	rmpath import;

	X = [armValues; legValues]; % Store all samples as X
	delayTEd40 = armDelayTEd40'; % Currently unused
	TEd40 = [armTEd40'; legTEd40']; % Currently unused
end

