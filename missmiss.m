% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs] = missmiss(iters)
	if nargin == 0
		iters = 1;
	end

	X = loadMEF();

	addpath missing

	covr = cov(X);

	% Set up functions to iterate through
	funcs = {
		@fillCCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillPCA,
		@fillMean,
		@fillRegr,
		@fillMI,
	};
	names = {
		'Listwise',
		'PCA (k=1)',
		'PCA (k=2)',
		'PCA (k=3)',
		'PCA (k=4)',
		'PCA (k=5)',
		'Mean-Fill',
		'Regression',
		'MI',
	};
	args = {
		{},
		1,
		2,
		3,
		4,
		5,
		{},
		{},
		{},
	};

	% Calculate errors
	verrs = [[]];
	cerrs = [[]];
	for i = 1:iters
		fprintf('Running iteration %d of %d...\n', i, iters);
		[verr, cerr] = testFuncs(funcs, X, covr, args);
		verrs = [verrs; verr];
		cerrs = [cerrs; cerr];
	end
	fprintf('\n');

	% Print table of values
	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev)\n');
	fprintf('-----------+-----------------------+----------------------------\n');
	for i = 1:length(funcs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', names{i}, num2str(mean(verrs(:, i)), '%.2f'), num2str(std(verrs(:, i)), '%.2f'), num2str(mean(cerrs(:, i)), '%.2f'), num2str(std(cerrs(:, i)), '%.2f'));
	end

	% Plot values
	plotBoxes(verrs, cerrs, names);

	% Calculate statistical significance
	calcStats(verrs, 2, length(funcs)) % Skip first value because it's CCA with NaN.
	calcStats(cerrs, 1, length(funcs))

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

function calcStats(data, startIdx, endIdx)
	[p, table, stats] = anova1(data);
	% [c, m, h, nms] = multcompare(stats, 'ctype', 'hsd');
	errs = [];
	for i = startIdx:endIdx
		errs = [errs; data(:, i) ones(size(data, 1), 1) + i - startIdx];
	end
	disp(errs)
	GHtest(errs);
end

function plotBoxes(verrs, cerrs, names)
	% Avoid plotting last one because it's CCA
	subplot(1, 2, 1);
	lengthWithoutLast = size(verrs, 2) - 1;
	boxplot(verrs(:, lengthWithoutLast), names(:, lengthWithoutLast));
	title('Error in Filled Data');
	xlabel('Method');
	ylabel('Error');

	subplot(1, 2, 2);
	boxplot(cerrs, names);
	title('Error in Covariance');
	xlabel('Method');
	ylabel('Error');
end
