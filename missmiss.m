% missmiss loads missing data and does stuff with it
function [missingX, completeX, mask, originalMissingX, missingMask] = missmiss(iters)
	if nargin == 0
		iters = 1;
	end

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

	verrs = [[]];
	cerrs = [[]];

	for i = 1:iters
		fprintf('Running iteration %d of %d...\n', i, iters);
		[missingX, completeX, mask, originalMissingX, missingMask] = deleteProportional(X);
		[verr, cerr] = testFuncs(funcs, missingX, completeX, mask, originalMissingX, missingMask, originalCov);
		verrs = [verrs; verr];
		cerrs = [cerrs; cerr];
	end
	fprintf('\n');

	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev)\n');
	fprintf('-----------+-----------------------+----------------------------\n');
	for i = 1:length(funcs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', func2str(funcs{i}), num2str(mean(verr(:, i)), '%.2f'), num2str(std(verr(:, i)), '%.2f'), num2str(mean(cerr(:, i)), '%.2f'), num2str(std(cerr(:, i)), '%.2f'));
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

function [verr, cerr] = testFuncs(funcs, missingX, completeX, mask, originalMissingX, missingMask, originalCov)
	verr = [];
	cerr = [];

	for i = 1:length(funcs)
		[filledX, covr] = funcs{i}(missingX, completeX, mask, originalMissingX, missingMask);
		verr = [verr valueError(missingX, originalMissingX, missingMask, filledX)];
		cerr = [cerr covError(originalCov, covr)];
	end
end
