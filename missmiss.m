% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, algs] = missmiss(varargin)
	p = inputParser;
	addOptional(p, 'algList', "quick", @(x) any(validatestring(x, {'small-n', 'quick', 'all', 'standard'})));
	addOptional(p, 'iters', 3, @(x) isnumeric(x) && x>0);
	addParameter(p, 'numToUse', 0, @(x) isnumeric(x) && x>=0); % Zero means all
	addParameter(p, 'parallelize', false, @islogical);
	addParameter(p, 'includeCheats', false, @islogical);
	addParameter(p, 'fixedSeed', true, @islogical);
	addParameter(p, 'displayPlot', true, @islogical);
	parse(p, varargin{:});

	if p.Results.fixedSeed
		seed = 7738;
	else
		s = rng('shuffle');
		seed = s.Seed;
	end

	X = loadMEF();

	addpath missing

	covr = cov(X);

	algs = getAlgList(p.Results.algList, size(X, 2));

	% Calculate errors
	verrs = zeros(p.Results.iters, length(algs));
	cerrs = zeros(p.Results.iters, length(algs));
	runtimes = zeros(p.Results.iters, length(algs));
	if p.Results.parallelize
		disp('Running parallel iterations...')
		parfor i = 1:p.Results.iters
			rng(seed+i*31);
			[verrs(i, :), cerrs(i, :), runtimes(i, :)] = testFuncs(algs, X, covr, p.Results.includeCheats, p.Results.parallelize, p.Results.numToUse);
		end
	else
		for i = 1:p.Results.iters
			rng(seed+i*31);
			fprintf('Iter %d of %d...', i, p.Results.iters);
			[verrs(i, :), cerrs(i, :), runtimes(i, :)] = testFuncs(algs, X, covr, p.Results.includeCheats, p.Results.parallelize, p.Results.numToUse);
		end
	end
	fprintf('\n');

	[~,~] = mkdir('bin/missmiss'); % Read and ignore returns to suppress warning if dir exists.
	save('bin/missmiss/vars.mat', 'X', 'covr', 'verrs', 'cerrs', 'algs');

	% Print table of values
	fprintf(' Algorithm | Value Error (std) | Covariance Error (std) | Time (std)     | n (of %d) \n', p.Results.iters);
	fprintf('-----------+-------------------+------------------------+----------------+-----------\n');
	for i = 1:length(algs)
		printTableRow(algs(i).name, verrs, cerrs, runtimes, i);
		if p.Results.includeCheats
			printTableRow(algs(i).name, verrs, cerrs, runtimes, length(algs)+i);
		end
	end

	if p.Results.displayPlot
		if p.Results.includeCheats
			algNames = [{algs.name}, strcat({algs.name}, '_X')];
		else
			algNames = {algs.name};
		end

		if p.Results.iters ~= 1
			% Calculate statistical significance
			calcStats(verrs, 'Value Errors', algNames)
			calcStats(cerrs, 'Covariance Errors', algNames)
			calcStats(runtimes, 'Runtimes', algNames)
		end

		% Plot values
		numSamples = p.Results.numToUse;
		if numSamples <= 0
			numSamples = size(X, 1);
		end
		plotBoxes(verrs, cerrs, runtimes, algNames, numSamples);
	end

	rmpath missing
end

function printTableRow(name, verrs, cerrs, runtimes, offset)
	vmn = truncateLargeValue(mean(verrs(:, offset), 'omitnan'));
	vst = truncateLargeValue(std(verrs(:, offset), 'omitnan'));
	cmn = truncateLargeValue(mean(cerrs(:, offset), 'omitnan'));
	cst = truncateLargeValue(std(cerrs(:, offset), 'omitnan'));
	rmn = truncateLargeValue(mean(runtimes(:, offset), 'omitnan'));
	rst = truncateLargeValue(std(runtimes(:, offset), 'omitnan'));
	num = sum(~isnan(verrs(:, offset)));
	fprintf('%10s | %10s (%5s) | %10s (%5s)    | %14s | %d \n', name, num2str(vmn, '%.1f'), num2str(vst, '%.1f'), num2str(cmn, '%.1f'), num2str(cst, '%.1f'), displayTime(rmn, rst), num);
end

function [str] = displayTime(mn, st)
	units = "s";
	if mn < 0.1 || st < 0.1
		mn = mn*1000;
		st = st*1000;
		units = "ms";
	elseif mn >= 10000 || st >= 10000
		mn = mn/1000;
		st = st/1000;
		units = "ks";
	end

	if mn < 10
		str = sprintf("%.2f (%.2f) %s", mn, st, units);
	elseif mn < 100
		str = sprintf("%.1f (%.1f) %s", mn, st, units);
	else
		str = sprintf("%.0f (%.0f) %s", mn, st, units);
	end
end

function [val] = truncateLargeValue(val)
	if val > 1e70
		val = Inf;
	end
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

function [verr, cerr, runtime] = testFuncs(algs, X, originalCov, includeCheats, parallelize, numToUse)
	parallelPrint('Load...', parallelize);
	X = selectSubset(X, numToUse);
	[missingX, completeX, ~, originalMissingX, missingMask] = deleteProportional(X);

	verr = [];
	cerr = [];
	runtime = [];

	seed = randi(2^32-1); % Generate a new seed randomly, but save it

	parallelPrint('Run ', parallelize);
	for i = 1:length(algs)
		tic;
		[ve, ce] = testFunc(algs(i), seed, originalCov, missingX, completeX, originalMissingX, missingMask, parallelize);
		runtime = [runtime toc];

		verr = [verr ve];
		cerr = [cerr ce];
	end
	parallelPrint('\n', parallelize);

	if includeCheats
		parallelPrint('\tCheat with ', parallelize);
		for i = 1:length(algs)
			tic;
			[ve, ce] = testFunc(algs(i), seed, originalCov, originalMissingX, completeX, originalMissingX, missingMask, parallelize);
			runtime = [runtime toc];

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
	fprintf("\n%s\n", name);
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

function plotBoxes(verrs, cerrs, runtimes, algNames, numSamples)
	vAlgNames = algNames;
	if (all(isnan(verrs(:, 1))))
		verrs = verrs(:, 2:end);
		vAlgNames = algNames(2:end);
	end

	[~,~] = mkdir('img/missmiss'); % Read and ignore returns to suppress warning if dir exists.
	pathstr = sprintf('img/missmiss/%d-%d-%d-%d%d%02.0f (%d samples)', clock, numSamples);

	valfig = plotOne('Error in Filled Data', 'Error', 'value', verrs, vAlgNames, pathstr, numSamples);
	covfig = plotOne('Error in Covariance', 'Error', 'covar', cerrs, algNames, pathstr, numSamples);
	runfig = plotOne('Runtimes', 'Time (ms)', 'times', runtimes, algNames, pathstr, numSamples);
	close(covfig);
end

function [handle] = plotOne(figname, label, prefix, vals, names, pathstr, numSamples)
	% Replace NaN and Inf with a really big number. This prevents errors in plotting.
	vals(isnan(vals)) = realmax;
	vals(isinf(vals)) = realmax;

	handle = figure('DefaultAxesFontSize', 18);

	addpath lib/CategoricalScatterplot
	CategoricalScatterplot(vals, names, 'MarkerSize', 50);
	rmpath lib/CategoricalScatterplot

	yl = ylim;
	if yl(2) > 10000
		ymax = max(vals(vals<10000));
		ylim([0 ymax]);
	end
	title(sprintf("%s (%d samples)", figname, numSamples));
	ylabel(label);
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

function [algs] = getAlgList(algList, sizeX)
	switch algList
		case 'quick'
			algs = [
				struct('func', @fillCCA, 'name', 'CCA', 'args', struct());
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'));
			];
		case 'standard'
			algs = [
				struct('func', @fillCCA, 'name', 'CCA', 'args', struct());
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 10, 'length', 100));
				struct('func', @fillTSR, 'name', 'TSR', 'args', struct('k', sizeX));
				struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'));
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
			];
		case 'small-n'
			algs = [
				struct('func', @fillCCA, 'name', 'CCA', 'args', struct());
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillTSR, 'name', 'TSR', 'args', struct('k', sizeX));
				struct('func', @fillPCA, 'name', 'PCA', 'args', struct('k', 6, 'VariableWeights', 'variance'));
				struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'));
				struct('func', @fillAutoencoder, 'name', 'AE', 'args', struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean'));
				struct('func', @fillCascadeAuto, 'name', 'Casc', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500));
				struct('func', @fillIterate, 'name', 'iPCA', 'args', struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 6, 'VariableWeights', 'variance', 'algorithm', 'eig')));
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
				struct('func', @fillIterate, 'name', 'iAE', 'args', struct('method', @fillAutoencoder, 'handleNaN', 'mean', 'iterations', 5, 'args', struct('nh', 6, 'trainMissingRows', true)));
			];
		case 'all'
			algs = [
				struct('func', @fillCCA, 'name', 'CCA', 'args', struct());
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 10, 'length', 100));
				struct('func', @fillTSR, 'name', 'TSR', 'args', struct('k', sizeX));
				struct('func', @fillTSR, 'name', 'TSR/2', 'args', struct('k', round(sizeX/2)));
				struct('func', @fillPCA, 'name', 'PCA6', 'args', struct('k', 6, 'VariableWeights', 'variance'));
				struct('func', @fillPCA, 'name', 'PCA13', 'args', struct('k', 13, 'VariableWeights', 'variance'));
				struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'));
				struct('func', @fillAutoencoder, 'name', 'AE6', 'args', struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean'));
				struct('func', @fillCascadeAuto, 'name', 'Casc6', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500));
				struct('func', @fillAutoencoder, 'name', 'AE13', 'args', struct('nh', 13, 'trainMissingRows', true, 'handleNaN', 'mean'));
				struct('func', @fillCascadeAuto, 'name', 'Casc13', 'args', struct('nh', 13, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500));
				struct('func', @fillIterate, 'name', 'iPCA', 'args', struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 6, 'VariableWeights', 'variance', 'algorithm', 'eig')));
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
				struct('func', @fillIterate, 'name', 'iAE', 'args', struct('method', @fillAutoencoder, 'handleNaN', 'mean', 'iterations', 5, 'args', struct('nh', 6, 'trainMissingRows', true)));
				struct('func', @fillIterate, 'name', 'iCasc', 'args', struct('method', @fillCascadeAuto, 'iterations', 5, 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)));
			];
		otherwise
			error("No algorithm list name was provided.")
	end
end
