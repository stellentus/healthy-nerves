% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, algs] = missmiss(iters, fixedSeed)
	if nargin == 0
		iters = 1;
		fixedSeed = false;
	elseif nargin == 1
		fixedSeed = false;
	end

	rng('shuffle'); % Make sure it's been reset in case a previous run set it.

	X = loadMEF();

	addpath missing

	covr = cov(X);

	% Set up functions to iterate through
	algs = [];
	algs = [algs; struct('func', @fillCCA, 'name', 'Listwise', 'args', [])];
	algs = [algs; struct('func', @fillMean, 'name', 'Mean-Fill', 'args', [])];
	algs = [algs; struct('func', @fillPCA, 'name', 'PCA (k=4)', 'args', 4)];
	algs = [algs; struct('func', @fillRegr, 'name', 'Regression', 'args', [])];
	algs = [algs; struct('func', @fillMI, 'name', 'MI', 'args', [])];
	algs = [algs; struct('func', @fillMultiNeural, 'name', 'MultiNeural', 'args', struct('nh', 2))];
	algs = [algs; struct('func', @fillAutoencoder, 'name', 'Autoencoder', 'args', struct('nh', 6))];

	% Calculate errors
	verrs = [[]];
	cerrs = [[]];
	for i = 1:iters
		if fixedSeed
			rng(i*31+11); % Make sure each run is the same
		end
		fprintf('Iter %d of %d...', i, iters);
		[verr, cerr] = testFuncs(algs, X, covr);
		verrs = [verrs; verr];
		cerrs = [cerrs; cerr];
	end
	fprintf('\n');

	save('bin/vars.mat', 'X', 'covr', 'verrs', 'cerrs', 'algs');

	% Print table of values
	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev)\n');
	fprintf('-----------+-----------------------+----------------------------\n');
	for i = 1:length(algs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', algs(i).name, num2str(mean(verrs(:, i)), '%.2f'), num2str(std(verrs(:, i)), '%.2f'), num2str(mean(cerrs(:, i)), '%.2f'), num2str(std(cerrs(:, i)), '%.2f'));
	end

	if iters ~= 1
		% Calculate statistical significance
		calcStats(verrs, 'Values', algs)
		calcStats(cerrs, 'Covariances', algs)
	end

	% Plot values
	plotBoxes(verrs, cerrs, algs);

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

function [verr, cerr] = testFuncs(algs, X, originalCov)
	fprintf('Load...');
	[missingX, completeX, mask, originalMissingX, missingMask] = deleteProportional(X);

	verr = [];
	cerr = [];

	seed = randi(2^32-1); % Generate a new seed randomly, but save it

	fprintf('Run ');
	for i = 1:length(algs)
		fprintf('%s...', algs(i).name);
		rng(seed); % Seed each algorithm with the exact same random numbers
		[filledX, covr] = algs(i).func(missingX, completeX, mask, originalMissingX, missingMask, algs(i).args);
		verr = [verr valueError(missingX, originalMissingX, missingMask, filledX)];
		cerr = [cerr covError(originalCov, covr)];
	end
	fprintf('\n');
end

function calcStats(data, name, algs)
	for i = 1:size(data, 2)
		for j = i+1:size(data, 2)
			[h, p] = ttest(data(:, i), data(:, j));
			if h == 1
				if p < 0.001
					fprintf('** %10s vs %10s is significant (p=%f)\n', algs(i).name, algs(j).name, p);
				else
					fprintf('*  %10s vs %10s is significant (p=%.3f)\n', algs(i).name, algs(j).name, p);
				end
			else
				fprintf('   %10s vs %10s is not significant (p=%.3f)\n', algs(i).name, algs(j).name, p);
			end
		end
	end
end

function plotBoxes(verrs, cerrs, algs)
	% Replace NaN with a really big number. This prevents errors in plotting.
	verrs(isnan(verrs)) = realmax;
	cerrs(isnan(cerrs)) = realmax;

	addpath util/CategoricalScatterplot

	figure('DefaultAxesFontSize', 18);

	subplot(1, 2, 1);
	CategoricalScatterplot(verrs, [char(algs.name)]);
	ylim([0 80]);
	title('A) Error in Filled Data');
	xlabel('Method');
	ylabel('Error');

	subplot(1, 2, 2);
	CategoricalScatterplot(cerrs, [char(algs.name)]);
	ylim([0 80]);
	title('B) Error in Covariance');
	xlabel('Method');
	ylabel('Error');

	rmpath util/CategoricalScatterplot
end
