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
		% @fillPCA,
		@fillMean,
		@fillRegr,
		% @fillMI,
		@fillNeural,
	};
	names = {
		'Listwise',
		% 'PCA (k=4)',
		'Mean-Fill',
		'Regression',
		% 'MI',
		'Neural',
	};
	args = {
		{},
		% 4,
		{},
		{},
		% {},
		struct(),
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

	if iters ~= 1
		% Calculate statistical significance
		calcStats(verrs, 'Values', names)
		calcStats(cerrs, 'Covariances', names)
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

function calcStats(data, name, names)
	for i = 1:size(data, 2)
		for j = i+1:size(data, 2)
			[h, p] = ttest(data(:, i), data(:, j));
			if h == 1
				if p < 0.001
					fprintf('** %10s vs %10s is significant (p=%f)\n', names{i}, names{j}, p);
				else
					fprintf('*  %10s vs %10s is significant (p=%.3f)\n', names{i}, names{j}, p);
				end
			else
				fprintf('   %10s vs %10s is not significant (p=%.3f)\n', names{i}, names{j}, p);
			end
		end
	end
end

function plotBoxes(verrs, cerrs, names)
	addpath util/CategoricalScatterplot

	figure('DefaultAxesFontSize', 18);

	subplot(1, 2, 1);
	CategoricalScatterplot(verrs(:, 2:size(verrs, 2)), names(2:size(verrs, 2)));
	ylim([0 80]);
	title('A) Error in Filled Data');
	xlabel('Method');
	ylabel('Error');

	subplot(1, 2, 2);
	CategoricalScatterplot(cerrs, names);
	ylim([0 70]);
	title('B) Error in Covariance');
	xlabel('Method');
	ylabel('Error');

	rmpath util/CategoricalScatterplot
end
