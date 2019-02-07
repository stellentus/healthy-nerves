% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, algs] = missmiss(iters, fixedSeed, displayPlot, includeCheats)
	if nargin < 4
		includeCheats = false;
	end
	if nargin < 3
		displayPlot = true;
	end
	if nargin < 2
		fixedSeed = false;
	end
	if nargin < 1
		iters = 1;
	end

	if fixedSeed
		seed = 7738;
	else
		s = rng('shuffle');
		seed = s.Seed;
	end

	X = loadMEF();

	addpath missing

	covr = cov(X);

	% Set up functions to iterate through
	algs = [];
	algs = [algs; struct('func', @fillCCA, 'name', 'CCA', 'args', struct())];
	algs = [algs; struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true))];
	algs = [algs; struct('func', @fillMI, 'name', 'MI', 'args', struct('number', 10, 'length', 100))];
	algs = [algs; struct('func', @fillPCA, 'name', 'PCA', 'args', struct('k', 6, 'VariableWeights', 'variance'))];
	algs = [algs; struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'))];
	algs = [algs; struct('func', @fillAutoencoder, 'name', 'AE', 'args', struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean'))];
	algs = [algs; struct('func', @fillCascadeAuto, 'name', 'Casc', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500))];
	% algs = [algs; struct('func', @fillIterate, 'name', 'iPCA', 'args', struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 6, 'VariableWeights', 'variance', 'algorithm', 'eig')))];
	algs = [algs; struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()))];
	% algs = [algs; struct('func', @fillIterate, 'name', 'iAE', 'args', struct('method', @fillAutoencoder, 'handleNaN', 'mean', 'iterations', 5, 'args', struct('nh', 6, 'trainMissingRows', true)))];
	algs = [algs; struct('func', @fillIterate, 'name', 'iCasc', 'args', struct('method', @fillCascadeAuto, 'iterations', 2, 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)))];

	% Calculate errors
	verrs = [[]];
	cerrs = [[]];
	verrs = zeros(iters, length(algs));
	cerrs = zeros(iters, length(algs));
	for i = 1:iters
		rng(seed+i*31);
		fprintf('Iter %d of %d...', i, iters);
		[verrs(i, :), cerrs(i, :)] = testFuncs(algs, X, covr, includeCheats);
	end
	fprintf('\n');

	save('bin/vars.mat', 'X', 'covr', 'verrs', 'cerrs', 'algs');

	% Print table of values
	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev)\n');
	fprintf('-----------+-----------------------+----------------------------\n');
	for i = 1:length(algs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', algs(i).name, num2str(mean(verrs(:, i)), '%.2f'), num2str(std(verrs(:, i)), '%.2f'), num2str(mean(cerrs(:, i)), '%.2f'), num2str(std(cerrs(:, i)), '%.2f'));
		if includeCheats
			offset = length(algs);
			fprintf('%10s | %11s (%5s)   | %11s (%5s)\n', strcat(algs(i).name, '_X'), num2str(mean(verrs(:, offset+i)), '%.2f'), num2str(std(verrs(:, offset+i)), '%.2f'), num2str(mean(cerrs(:, offset+i)), '%.2f'), num2str(std(cerrs(:, offset+i)), '%.2f'));
		end
	end

	if displayPlot
		if includeCheats
			algNames = [{algs.name}, strcat({algs.name}, '_X')];
		else
			algNames = {algs.name};
		end

		if iters ~= 1
			% Calculate statistical significance
			calcStats(verrs, 'value', algNames)
			calcStats(cerrs, 'covariance', algNames)
		end

		% Plot values
		plotBoxes(verrs, cerrs, algNames);
	end

	rmpath missing
end

function [X] = loadMEF()
	addpath import;
	[armValues, armParticipants] = mefimport(pathFor('arm'), true);
	[legValues, legParticipants] = mefimport(pathFor('leg'), true);

	% [armDelayTEd40, armDelayTEh40, ~, ~, armTEd40, armTEh40, ~, ~] = mefTEimport(pathFor('arm'), armParticipants);
	% [legDelayTEd40, legDelayTEh40, ~, ~, legTEd40, legTEh40, ~, ~] = mefTEimport(pathFor('leg'), legParticipants);
	rmpath import;

	X = [armValues; legValues]; % Store all samples as X
	% delayTEd40 = armDelayTEd40'; % Currently unused
	% TEd40 = [armTEd40'; legTEd40']; % Currently unused
end

function [verr, cerr] = testFuncs(algs, X, originalCov, includeCheats)
	fprintf('Load...');
	[missingX, completeX, ~, originalMissingX, missingMask] = deleteProportional(X);

	verr = [];
	cerr = [];

	seed = randi(2^32-1); % Generate a new seed randomly, but save it

	fprintf('Run ');
	for i = 1:length(algs)
		[ve, ce] = testFunc(algs(i), seed, originalCov, missingX, completeX, originalMissingX, missingMask);

		verr = [verr ve];
		cerr = [cerr ce];
	end
	fprintf('\n');

	if includeCheats
		fprintf('\tCheat with ');
		for i = 1:length(algs)
			[ve, ce] = testFunc(algs(i), seed, originalCov, originalMissingX, completeX, originalMissingX, missingMask);

			verr = [verr ve];
			cerr = [cerr ce];
		end
		fprintf('\n');
	end
end

function [ve, ce, filledX] = testFunc(alg, seed, originalCov, missingX, completeX, originalMissingX, missingMask)
	fprintf('%s...', alg.name);
	rng(seed); % Seed each algorithm with the exact same random numbers

	switch nargout(alg.func)
		case 1
			% If the function only has one output argument, it doesn't do anything special to calculate covariance
			filledX = alg.func(missingX, completeX, missingMask, alg.args);
			filledX = updateKnownValues(filledX, missingX, missingMask); % Add originalMissingX as a fourth argument to print debug
			covr = cov([completeX; filledX]);
		otherwise
			[filledX, covr] = alg.func(missingX, completeX, missingMask, alg.args);
			filledX = updateKnownValues(filledX, missingX, missingMask); % Add originalMissingX as a fourth argument to print debug
	end

	ve = mean(mean(((originalMissingX - filledX) .* ~missingMask) .^ 2));
	ce = mean(mean((originalCov - covr) .^ 2));
end

function calcStats(data, name, algNames)
	for i = 1:size(data, 2)
		for j = i+1:size(data, 2)
			[h, p] = ttest(data(:, i), data(:, j));
			iName = algNames{i};
			jName = algNames{j};
			if h == 1
				if p < 0.001
					fprintf('** %10s vs %10s is significant (p=%f)\n', iName, jName, p);
				else
					fprintf('*  %10s vs %10s is significant (p=%.3f)\n', iName, jName, p);
				end
			else
				fprintf('   %10s vs %10s is not significant (p=%.3f)\n', iName, jName, p);
			end
		end
	end
end

function plotBoxes(verrs, cerrs, algNames)
	vAlgNames = algNames;
	if (all(isnan(verrs(:, 1))))
		verrs = verrs(:, 2:end);
		vAlgNames = algNames(2:end);
	end

	% Replace NaN with a really big number. This prevents errors in plotting.
	verrs(isnan(verrs)) = realmax;
	cerrs(isnan(cerrs)) = realmax;

	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	redColor = [1 0.1490196078431372549 0];
	yellowColor = [0.98039215686274509804 0.8509803921568627451 0.25882352941176470588];

	addpath lib/CategoricalScatterplot

	pathstr = sprintf('img/%d-%d-%d-%d%d%2.0f', clock);

	valfig = figure('DefaultAxesFontSize', 18);
	ax = gca;
	ax.YColor = greenColor;
	ax.XColor = greenColor;
	CategoricalScatterplot(verrs, vAlgNames, 'MarkerSize', 50, 'WhiskerColor', 'k', 'MedianColor', 'k', 'BoxColor', yellowColor, 'BoxAlpha', .29);
	ylim([0 30]);
	title('Error in Filled Data', 'Color', greenColor);
	% xlabel('Method', 'Color', greenColor);
	ylabel('Error', 'Color', greenColor);
	savefig(valfig, strcat(pathstr, ' Value.fig', 'compact'));
	saveas(valfig, strcat(pathstr, ' Value.png'));

	covfig = figure('DefaultAxesFontSize', 18);
	ax = gca;
	ax.YColor = greenColor;
	ax.XColor = greenColor;
	CategoricalScatterplot(cerrs, algNames, 'MarkerSize', 50, 'WhiskerColor', 'k', 'MedianColor', 'k', 'BoxColor', yellowColor, 'BoxAlpha', .29);
	ylim([0 30]);
	title('Error in Covariance', 'Color', greenColor);
	% xlabel('Method', 'Color', greenColor);
	ylabel('Error', 'Color', greenColor);
	savefig(covfig, strcat(pathstr, ' Covariance.fig', 'compact'));
	saveas(covfig, strcat(pathstr, ' Covariance.png'));

	rmpath lib/CategoricalScatterplot
end
