% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs] = missmiss(iters)
	if nargin == 0
		iters = 1;
	end

	X = loadMEF();

	addpath missing

	covr = cov(X);

	funcs = {
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillCCA,
		@fillMean,
		@fillRegr,
		@fillMI,
	};
	names = {
		'PCA (k=3)',
		'PCA (k=4)',
		'PCA (k=5)',
		'PCA (k=6)',
		'PCA (k=7)',
		'PCA (k=8)',
		'PCA (k=9)',
		'Listwise',
		'Mean-Fill',
		'Regression',
		'MI',
	};
	args = {
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		{},
		{},
		{},
		{},
	};

	verrs = [[]];
	cerrs = [[]];

	for i = 1:iters
		fprintf('Running iteration %d of %d...\n', i, iters);
		[verr, cerr] = testFuncs(funcs, X, covr, args);
		verrs = [verrs; verr];
		cerrs = [cerrs; cerr];
	end
	fprintf('\n');

	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev)\n');
	fprintf('-----------+-----------------------+----------------------------\n');
	for i = 1:length(funcs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', names{i}, num2str(mean(verrs(:, i)), '%.2f'), num2str(std(verrs(:, i)), '%.2f'), num2str(mean(cerrs(:, i)), '%.2f'), num2str(std(cerrs(:, i)), '%.2f'));
	end

	plotBoxes(verrs, cerrs, names);

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

function [verr, cerr] = testFuncs(funcs, X, originalCov, args)
	[missingX, completeX, mask, originalMissingX, missingMask] = deleteProportional(X);

	verr = [];
	cerr = [];

	for i = 1:length(funcs)
		[filledX, covr] = funcs{i}(missingX, completeX, mask, originalMissingX, missingMask, args{i});
		verr = [verr valueError(missingX, originalMissingX, missingMask, filledX)];
		cerr = [cerr covError(originalCov, covr)];
	end
end

function plotBoxes(verrs, cerrs, names)
	subplot(1, 2, 1);
	boxplot(verrs, names);
	title('Error in Filled Data');
	xlabel('Method');
	ylabel('Error');

	subplot(1, 2, 2);
	boxplot(cerrs, names);
	title('Error in Covariance');
	xlabel('Method');
	ylabel('Error');
end
