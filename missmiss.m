% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, algs] = missmiss(iters, fixedSeed, displayPlot)
	if nargin == 0
		iters = 1;
		fixedSeed = false;
		displayPlot = true;
	elseif nargin == 1
		fixedSeed = false;
		displayPlot = true;
	elseif nargin == 2
		displayPlot = true;
	end

	rng('shuffle'); % Make sure it's been reset in case a previous run set it.

	X = loadMEF();

	addpath missing

	covr = cov(X);

	% Set up functions to iterate through
	algs = [];
	algs = [algs; struct('func', @fillCCA, 'name', 'Listwise', 'args', [])];
	algs = [algs; struct('func', @fillMean, 'name', 'Mean-Fill', 'args', [])];
	algs = [algs; struct('func', @fillPCA, 'name', 'PCA (k=4)', 'args', struct('k', 4, 'VariableWeights', 'variance', 'zeroNaN',  true))];
	algs = [algs; struct('func', @fillRegr, 'name', 'Regression', 'args', [])];
	algs = [algs; struct('func', @fillMI, 'name', '    MI', 'args', struct('number', 10, 'length', 100))];
	algs = [algs; struct('func', @fillAutoencoder, 'name', 'Autoencode', 'args', struct('nh', 6, 'useAll', true))];
	algs = [algs; struct('func', @fillHungry, 'name', 'Hungry', 'args', struct('nh', 6))];
	algs = [algs; struct('func', @fillCascadeAuto, 'name', 'Cascade', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500))];
	algs = [algs; struct('func', @fillCascadeAuto, 'name', 'CascNoAuto', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500, 'useautoencoder', false))];

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

	if displayPlot
		if iters ~= 1
			% Calculate statistical significance
			calcStats(verrs, 'Values', algs)
			calcStats(cerrs, 'Covariances', algs)
		end

		% Plot values
		plotBoxes(verrs, cerrs, algs);
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

		switch nargout(algs(i).func)
			case 1
				% If the function only has one output argument, it doesn't do anything special to calculate covariance
				filledX = algs(i).func(missingX, completeX, mask, originalMissingX, missingMask, algs(i).args);
				filledX = predictOnlyMissingValues(filledX, missingX, missingMask, originalMissingX);
				covr = cov([completeX; filledX]);
			otherwise
				[filledX, covr] = algs(i).func(missingX, completeX, mask, originalMissingX, missingMask, algs(i).args);
				filledX = predictOnlyMissingValues(filledX, missingX, missingMask, originalMissingX);
		end

		verr = [verr mean(mean(((originalMissingX - filledX) .* ~missingMask) .^ 2))];
		cerr = [cerr mean(mean((originalCov - covr) .^ 2))];
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
	CategoricalScatterplot(verrs, [char(algs.name)]);
	ylim([0 30]);
	title('A) Error in Filled Data');
	xlabel('Method');
	ylabel('Error');

	figure('DefaultAxesFontSize', 18);
	CategoricalScatterplot(cerrs, [char(algs.name)]);
	ylim([0 30]);
	title('B) Error in Covariance');
	xlabel('Method');
	ylabel('Error');

	rmpath util/CategoricalScatterplot
end

function [missingX] = predictOnlyMissingValues(predictedX, missingX, missingMask, originalMissingX)
	[numSamplesMissing, numFeatures] = size(missingX);
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			continue
		end

		for i = 1:numSamplesMissing
			if 0 == missingMask(i, j)
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, predictedX(i, j), originalMissingX(i, j))
				missingX(i, j) = predictedX(i, j);
			end
		end
	end
end
