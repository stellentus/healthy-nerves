% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, names] = missmiss(iters)
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
		@fillMean,
		@fillRegr,
		@fillMI,
	};
	names = {
		'Listwise',
		'PCA (k=4)',
		'Mean-Fill',
		'Regression',
		'MI',
	};
	args = {
		{},
		4,
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

	save('bin/vars.mat', 'X', 'covr', 'verrs', 'cerrs', 'names');

	% Print table of values
	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev)\n');
	fprintf('-----------+-----------------------+----------------------------\n');
	for i = 1:length(funcs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', names{i}, num2str(mean(verrs(:, i)), '%.2f'), num2str(std(verrs(:, i)), '%.2f'), num2str(mean(cerrs(:, i)), '%.2f'), num2str(std(cerrs(:, i)), '%.2f'));
	end

	% Plot values
	plotBoxes(verrs, cerrs, names);

	% Calculate statistical significance
	calcStats(verrs, 'Values')
	calcStats(cerrs, 'Covariances')

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

function calcStats(data, name)
	% First, does ANOVA say the difference is significant?
	[p, table, stats] = anova1(data, [], 'off');
	if p < 0.001
		fprintf('\n%s ANOVA ($F(%d, %d) = %.2f, p < 0.001$)\n', name, table{2, 3}, table{3, 3}, table{2, 5});
	else
		fprintf('\n%s ANOVA ($F(%d, %d) = %.2f, p = %.3f$)\n', name, table{2, 3}, table{3, 3}, table{2, 5}, table{2, 6});
	end

	% Next check for significance.
	% [c, m, h, nms] = multcompare(stats, 'ctype', 'hsd');

	% Or use GH test for significance.
	errs = [];
	for i = 1:size(data, 2)
		errs = [errs; data(:, i) ones(size(data, 1), 1) + i - 1];
	end
	GHtest(errs);
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
