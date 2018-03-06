% missmiss loads missing data and does stuff with it
function [missingX, completeX, mask, originalMissingX, missingMask] = missmiss()
	X = loadMEF();

	addpath missing

	originalCov = cov(X);

	funcs = {
		@fillPCA,
		@fillCCA,
		@fillMean,
		@fillRegr,
		@fillMI,
	};

	[missingX, completeX, mask, originalMissingX, missingMask] = deleteProportional(X);

	verr = [];
	cerr = [];

	for i = 1:length(funcs)
		[filledX, covr] = funcs{i}(missingX, completeX, mask, originalMissingX, missingMask);
		verr = [verr valueError(missingX, originalMissingX, missingMask, filledX)];
		cerr = [cerr covError(originalCov, covr)];
	end

	fprintf(' Algorithm | Value Error | Covariance Error\n');
	fprintf('-----------+-------------+------------------\n');
	for i = 1:length(funcs)
		fprintf('%10s | %9s   | %9s\n', func2str(funcs{i}), num2str(verr(i), '%.2f'), num2str(cerr(i), '%.2f'));
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

