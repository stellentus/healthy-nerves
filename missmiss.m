% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, algs] = missmiss(iters, parallelize, fixedSeed, displayPlot, includeCheats, numToUse)
	if nargin < 6
		numToUse = 0; % Zero means all
	end
	if nargin < 5
		includeCheats = false;
	end
	if nargin < 4
		displayPlot = true;
	end
	if nargin < 3
		fixedSeed = false;
	end
	if nargin < 2
		parallelize = false;
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
	algs = [algs; struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 10, 'length', 100))];
	algs = [algs; struct('func', @fillTSR, 'name', 'TSR', 'args', struct('k', size(X, 2)))];
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
	if parallelize
		disp('Running parallel iterations...')
		parfor i = 1:iters
			rng(seed+i*31);
			[verrs(i, :), cerrs(i, :)] = testFuncs(algs, X, covr, includeCheats, parallelize, numToUse);
		end
	else
		for i = 1:iters
			rng(seed+i*31);
			fprintf('Iter %d of %d...', i, iters);
			[verrs(i, :), cerrs(i, :)] = testFuncs(algs, X, covr, includeCheats, parallelize, numToUse);
		end
	end
	fprintf('\n');

	save('bin/vars.mat', 'X', 'covr', 'verrs', 'cerrs', 'algs');

	% Print table of values
	fprintf(' Algorithm | Value Error (std dev) | Covariance Error (std dev) | n (of %d) \n', iters);
	fprintf('-----------+-----------------------+----------------------------+-----------\n');
	for i = 1:length(algs)
		fprintf('%10s | %11s (%5s)   | %11s (%5s)       | %d\n', algs(i).name, num2str(mean(verrs(:, i), 'omitnan'), '%.2f'), num2str(std(verrs(:, i), 'omitnan'), '%.2f'), num2str(mean(cerrs(:, i), 'omitnan'), '%.2f'), num2str(std(cerrs(:, i), 'omitnan'), '%.2f'), sum(~isnan(verrs(:, i))));
		if includeCheats
			offset = length(algs);
			fprintf('%10s | %11s (%5s)   | %11s (%5s)       | %d\n', strcat(algs(i).name, '_X'), num2str(mean(verrs(:, offset+i), 'omitnan'), '%.2f'), num2str(std(verrs(:, offset+i), 'omitnan'), '%.2f'), num2str(mean(cerrs(:, offset+i), 'omitnan'), '%.2f'), num2str(std(cerrs(:, offset+i), 'omitnan'), '%.2f'), sum(~isnan(verrs(:, offset+i))));
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
		if numToUse <= 0
			numToUse = size(X, 1);
		end
		plotBoxes(verrs, cerrs, algNames, numToUse);
	end

	rmpath missing
end

function [values] = loadMEF()
	filepath = "bin/batch-normative.mat";
	load(filepath);
	values = [canValues; japValues; porValues];
	participants = [canParticipants; japParticipants; porParticipants];

	% Delete NaN, since we want to test on the full rows.
	addpath import;
	[participants, values] = deleteNaN(participants, values);
	rmpath import;
end

function [verr, cerr] = testFuncs(algs, X, originalCov, includeCheats, parallelize, numToUse)
	parallelPrint('Load...', parallelize);
	X = selectSubset(X, numToUse);
	[missingX, completeX, ~, originalMissingX, missingMask] = deleteProportional(X);

	verr = [];
	cerr = [];

	seed = randi(2^32-1); % Generate a new seed randomly, but save it

	parallelPrint('Run ', parallelize);
	for i = 1:length(algs)
		[ve, ce] = testFunc(algs(i), seed, originalCov, missingX, completeX, originalMissingX, missingMask, parallelize);

		verr = [verr ve];
		cerr = [cerr ce];
	end
	parallelPrint('\n', parallelize);

	if includeCheats
		parallelPrint('\tCheat with ', parallelize);
		for i = 1:length(algs)
			[ve, ce] = testFunc(algs(i), seed, originalCov, originalMissingX, completeX, originalMissingX, missingMask, parallelize);

			verr = [verr ve];
			cerr = [cerr ce];
		end
		parallelPrint('\n', parallelize);
	end
end

function [ve, ce, filledX] = testFunc(alg, seed, originalCov, missingX, completeX, originalMissingX, missingMask, parallelize)
	parallelPrint(strcat(alg.name, '...'), parallelize);
	rng(seed); % Seed each algorithm with the exact same random numbers

	try
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
	catch
		filledX = missingX;    % Nothing is filled due to the error...
		covr = cov(completeX); % ...so covariance is only based on complete rows.
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

function plotBoxes(verrs, cerrs, algNames, numSamples)
	vAlgNames = algNames;
	if (all(isnan(verrs(:, 1))))
		verrs = verrs(:, 2:end);
		vAlgNames = algNames(2:end);
	end

	pathstr = sprintf('img/missmiss/%d-%d-%d-%d%d%2.0f (%d samples)', clock, numSamples);

	valfig = plotOne('Filled Data', 'value', verrs, vAlgNames, pathstr);
	covfig = plotOne('Covariance', 'covar', cerrs, algNames, pathstr);
	close(covfig);
end

function [handle] = plotOne(figname, prefix, vals, names, pathstr)
	% Replace NaN and Inf with a really big number. This prevents errors in plotting.
	vals(isnan(vals)) = realmax;
	vals(isinf(vals)) = realmax;

	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	redColor = [1 0.1490196078431372549 0];
	yellowColor = [0.98039215686274509804 0.8509803921568627451 0.25882352941176470588];

	handle = figure('DefaultAxesFontSize', 18);
	ax = gca;
	ax.YColor = greenColor;
	ax.XColor = greenColor;

	addpath lib/CategoricalScatterplot
	CategoricalScatterplot(vals, names, 'MarkerSize', 50, 'WhiskerColor', 'k', 'MedianColor', 'k', 'BoxColor', yellowColor, 'BoxAlpha', .29);
	rmpath lib/CategoricalScatterplot

	yl = ylim;
	if yl(2) > 10000
		ymax = max(vals(vals~=realmax));
		ylim([0 ymax]);
	end
	title(strcat("Error in ", figname), 'Color', greenColor);
	ylabel('Error', 'Color', greenColor);
	savefig(handle, strcat(pathstr, '-', prefix,  '.fig'), 'compact');
	saveas(handle, strcat(pathstr, '-', prefix,  '.png'));
end

function parallelPrint(str, parallelize)
	if ~parallelize
		fprintf(str);
	else
		fprintf('.')
	end
end

function [X] = selectSubset(X, numToUse)
	num = size(X, 1);

	if numToUse > 0
		X = X(randsample(num, numToUse), :); % Sample without replacement
	end
end
