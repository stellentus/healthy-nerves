% missmiss loads missing data and does stuff with it
function [X, covr, verrs, cerrs, algs] = missmiss(varargin)
	p = inputParser;
	addOptional(p, 'algList', "quick", @(x) any(validatestring(x, {'smalln', 'quick', 'all', 'standard', 'PCA', 'TSR', 'AE', 'cascade', 'DA'})));
	addOptional(p, 'iters', 3, @(x) isnumeric(x) && x>0);
	addParameter(p, 'numToUse', 0, @(x) isnumeric(x) && x>=0); % Zero means all
	addParameter(p, 'parallelize', false, @islogical);
	addParameter(p, 'includeCheats', false, @islogical);
	addParameter(p, 'fixedSeed', true, @islogical);
	addParameter(p, 'displayPlot', true, @islogical);
	addParameter(p, 'zmuvFromComplete', false, @islogical);
	addParameter(p, 'file', "bin/missing-normative.mat", @isstring);
	parse(p, varargin{:});

	if p.Results.fixedSeed
		seed = 7738;
	else
		s = rng('shuffle');
		seed = s.Seed;
	end

	X = loadMEF(p.Results.file);

	numSamples = p.Results.numToUse;
	if numSamples <= 0
		numSamples = size(X, 1);
	end

	% Log all output to a file
	basepath = 'img/missmiss/';
	[~,~] = mkdir(basepath); % Read and ignore returns to suppress warning if dir exists.
	name = sprintf('%d-%s', numSamples, p.Results.algList);
	nameStr = sprintf('%02d-%02d-%02d-%02d-%02d-%02.0f (%s)', clock, name);
	diary(strcat(basepath, nameStr, '.txt'));
	diary on;
	disp(p.Results);

	addpath missing

	covr = cov(X);

	algs = getAlgList(p.Results.algList, size(X, 2));

	if p.Results.zmuvFromComplete
		len = length(algs);
		for i=1:len
			al = algs(i);
			b = struct();
			for fn = fieldnames(al)'
				b.(fn{1}) = al.(fn{1});
			end
			b.args.zmuvFromComplete = true;
			b.name = char(strcat(b.name, " ZM"));
			algs = [algs; b];
		end
	end

	% Calculate errors
	verrs = zeros(p.Results.iters, length(algs));
	cerrs = zeros(p.Results.iters, length(algs));
	runtimes = zeros(p.Results.iters, length(algs));
	nMissing = zeros(p.Results.iters, 1);
	if p.Results.parallelize
		disp('Running parallel iterations...')
		parfor i = 1:p.Results.iters
			rng(seed+i*31);
			[verrs(i, :), cerrs(i, :), runtimes(i, :), nMissing(i)] = testFuncs(algs, X, covr, p.Results.includeCheats, p.Results.parallelize, p.Results.numToUse);
		end
	else
		for i = 1:p.Results.iters
			rng(seed+i*31);
			fprintf('Iter %d of %d...', i, p.Results.iters);
			[verrs(i, :), cerrs(i, :), runtimes(i, :), nMissing(i)] = testFuncs(algs, X, covr, p.Results.includeCheats, p.Results.parallelize, p.Results.numToUse);
		end
	end
	fprintf('\n');

	[~,~] = mkdir('bin/missmiss'); % Read and ignore returns to suppress warning if dir exists.
	save('bin/missmiss/vars.mat', 'X', 'covr', 'verrs', 'cerrs', 'algs');

	fprintf("There were an average of %.1f (%.2f) missing and %.1f complete.\n\n", mean(nMissing), std(nMissing), size(X, 1) - mean(nMissing));

	% Print table of values
	fprintf(' Algorithm | Value Error (std)  | Covar Error (std)  | Time (std)     | n (of %d) \n', p.Results.iters);
	fprintf('-----------+--------------------+--------------------+----------------+-----------\n');
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
			calcStats(verrs, 'Value Errors', algNames);
			calcStats(cerrs, 'Covariance Errors', algNames); % Note this compares to the original, true covariance matrix. If numToUse>0, a prophetic data-filling algorithm would do poorly here because even covariance elements between complete features will be different (since they're calculated on a subset of the data).
			calcStats(runtimes, 'Runtimes', algNames);
		end

		% Plot values
		plotBoxes(verrs, cerrs, runtimes, algNames, numSamples, nameStr, basepath, name);
	end

	rmpath missing;

	diary off;
end

function printTableRow(name, verrs, cerrs, runtimes, offset)
	vmn = truncateLargeValue(mean(verrs(:, offset), 'omitnan'));
	vst = truncateLargeValue(std(verrs(:, offset), 'omitnan'));
	cmn = truncateLargeValue(mean(cerrs(:, offset), 'omitnan'));
	cst = truncateLargeValue(std(cerrs(:, offset), 'omitnan'));
	rmn = truncateLargeValue(mean(runtimes(:, offset), 'omitnan'));
	rst = truncateLargeValue(std(runtimes(:, offset), 'omitnan'));
	num = sum(~isnan(verrs(:, offset)));
	fprintf('%10s | %9s (%6s) | %9s (%6s) | %14s | %d \n', name, num2str(vmn, '%.4f'), num2str(vst, '%.3f'), num2str(cmn, '%.2f'), num2str(cst, '%.2f'), displayTime(rmn, rst), num);
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

	if mn < 10 && st < 10
		str = sprintf("%.2f (%.2f) %2s", mn, st, units);
	elseif mn < 100 && st < 100
		str = sprintf("%.1f (%.1f) %2s", mn, st, units);
	else
		str = sprintf("%.0f (%.0f) %2s", mn, st, units);
	end
end

function [val] = truncateLargeValue(val)
	if val > 1e70
		val = Inf;
	end
end

function [values] = loadMEF(filepath)
	load(filepath);
	values = [canValues; japValues; porValues];
	participants = [canParticipants; japParticipants; porParticipants];

	% Delete NaN, since we want to test on the full rows.
	addpath import;
	[participants, values] = deleteNaN(participants, values);
	rmpath import;
end

function [verr, cerr, runtime, nMissing] = testFuncs(algs, X, originalCov, includeCheats, parallelize, numToUse)
	parallelPrint('Load...', parallelize);
	X = selectSubset(X, numToUse);
	[missingX, completeX, ~, originalMissingX, missingMask] = deleteProportional(X);
	nMissing = size(missingX, 1);

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

	originalCompleteX = completeX;

	if ~isfield(alg.args, 'zmuv')
		alg.args.zmuv = false;
	end
	if ~isfield(alg.args, 'zmuvFromComplete')
		alg.args.zmuvFromComplete = false;
	end
	if alg.args.zmuvFromComplete
		mn = mean(completeX);
		st = std(completeX);
		completeX = (completeX - mn) ./ st;
		missingX = (missingX - mn) ./ st;
	elseif alg.args.zmuv
		mn = mean([completeX; missingX], 'omitnan');
		st = std([completeX; missingX], 'omitnan');
		completeX = (completeX - mn) ./ st;
		missingX = (missingX - mn) ./ st;
	end

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

	if alg.args.zmuv || alg.args.zmuvFromComplete
		filledX = (filledX .* st) + mn;
		covr = covr.*st.*st';
	end

	ve = ((originalMissingX - filledX) ./ std(originalCompleteX)) .^ 2; % First calculate the squared error for the entire matrix (which will be zero in many cases). It should be normalized by the standard deviation to equally weight the features.
	ve = sum(sum(ve(~missingMask)))/sum(sum(~missingMask));     % Now sum the squared error (but only for missing elements) and divide by the number of missing elements, giving the MSE.
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

function plotBoxes(verrs, cerrs, runtimes, algNames, numSamples, nameStr, basepath, name)
	vAlgNames = algNames;
	if (all(isnan(verrs(:, 1))))
		verrs = verrs(:, 2:end);
		vAlgNames = algNames(2:end);
	end

	pathstr = strcat(basepath, nameStr);
	shortstr = strcat(basepath, name);

	valfig = plotOne('Error in Filled Data', 'Error', 'value', verrs, vAlgNames, pathstr, shortstr, numSamples, false);
	covfig = plotOne('Error in Covariance', 'Error', 'covar', cerrs, algNames, pathstr, shortstr, numSamples, false);
	runfig = plotOne('Runtimes', 'Time (s)', 'times', runtimes, algNames, pathstr, shortstr, numSamples, true);
	close(covfig);
end

function [handle] = plotOne(figname, label, prefix, vals, names, pathstr, shortstr, numSamples, isLog)
	% Replace NaN and Inf with a really big number. This prevents errors in plotting.
	vals(isnan(vals)) = realmax;
	vals(isinf(vals)) = realmax;

	handle = figure('DefaultAxesFontSize', 18);

	if isLog
		% This command just forces the plot to be logarithmic.
		semilogy(vals(1));
		hold on;
	end

	addpath lib/CategoricalScatterplot
	CategoricalScatterplot(vals, names, 'MarkerSize', 20);
	rmpath lib/CategoricalScatterplot

	if length(names) > 6
		xtickangle(45);
	end
	yl = ylim;
	if yl(2) > 10000
		ymax = max(vals(vals<10000));
		ylim([0 ymax]);
	end
	title(sprintf("%s (%d samples)", figname, numSamples));
	ylabel(label);

	pathstr = strcat(pathstr, '-', prefix);
	savefig(handle, strcat(pathstr,  '.fig'), 'compact');
	saveas(handle, strcat(pathstr,  '.png'));
	copyfile(strcat(pathstr, '.png'), strcat(shortstr, '-', prefix, '.png')); % Also save without timestamp
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
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
			];
		case 'standard'
			algs = [
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 2, 'length', 2, 'zmuv', true));
				struct('func', @fillPCA, 'name', 'PCA', 'args', struct('k', 6, 'VariableWeights', 'variance'));
				struct('func', @fillIterate, 'name', 'iPCA', 'args', struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 7, 'VariableWeights', 'variance', 'algorithm', 'eig')));
				struct('func', @fillAutoencoder, 'name', 'AE', 'args', struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean', 'zmuv', true));
				struct('func', @fillIterate, 'name', 'iAE', 'args', struct('method', @fillAutoencoder, 'handleNaN', 'mean', 'iterations', 5, 'zmuv', true, 'args', struct('nh', 6, 'trainMissingRows', true)));
				struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'));
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
				struct('func', @fillCascadeAuto, 'name', 'Casc', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500, 'zmuv', true));
				struct('func', @fillIterate, 'name', 'iCasc', 'args', struct('method', @fillCascadeAuto, 'iterations', 5, 'zmuv', true, 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)));
			];
		case 'smalln' % Designed for numToUse=40.
			% DA cannot handle such small n. BUT maybe it works better with ZMUV.
			% Casc with 1000 iterations instead of 500 is not significantly better (999 runs, p=0.103).
			algs = [
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillPCA, 'name', 'PCA', 'args', struct('k', 7, 'VariableWeights', 'variance'));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 2, 'length', 2, 'zmuv', true));
				struct('func', @fillAutoencoder, 'name', 'AE', 'args', struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean', 'zmuv', true));
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'zmuv', true, 'args', struct()));
				struct('func', @fillIterate, 'name', 'iPCA', 'args', struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 7, 'VariableWeights', 'variance', 'algorithm', 'eig')));
				struct('func', @fillCascadeAuto, 'name', 'Casc', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500, 'zmuv', true));
				struct('func', @fillIterate, 'name', 'iCasc', 'args', struct('method', @fillCascadeAuto, 'iterations', 2, 'zmuv', true, 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)));
			];
		case 'all'
			% Mean, Regr, AE, iAE and iCasc aren't that good at any numToUse.
			% I want to find one that works well at any numToUse because it's good to be insenstive to it.
			% Sadly, different algorithms are best at different numbers. But some are good at all numbers and best at others.
			% I might eventually want to plot performance as a function of numToUse (with a 95% CI of all of my runs).
			% 	Overall best is Casc6Z. It's tied for small n, slightly better than others for medium, and tied for second with full n.
			% 	However, iRegr outperforms it for the full dataset.
			%	iCasc with and without zmuv are oddly identical when zmuv is done inside each iteration (but zmuv outside iterations is better), while Casc behavior is much better with zmuv. (True for all 3 tests.)
			% 	iAE was terrible without zmuv, but with zmuv it performs in line with all of the others.
			% 	All of the below results are with zmuv except Regr, CCA, Mean, TSR, and PCA. (But PCA has built-in zmuv.)
			% 	iCasc with 2 or 5 iterations gives almost identical performance for 244 samples. Perhaps it's converging?
			% 	At lower numbers of samples, TSR performs a lot better (though still not among the best) when k is decreased.
			% numToUse=244 (all)
			% 	Pretty bad: Mean.
			% 	Second-best: iAE, Casc (nh 6 or 1), and iCasc (nh 6 or 1). Differences are not significant between Casc and iCasc.
			% 	Best: DA, TSR, and iRegr (mean variant). iRegr is significantly worse than other two.
			%	Runtimes: iRegr (65ms); DA and TSR (100ms); Casc (55s); and iCasc (110s).
			% numToUse=100
			% 	Good: DA, TSR (all or 6), iAE, iRegr, Casc, iCasc.
			% 	Best: Casc and iCasc (both with nh 6) are significantly better.
			% 	Runtimes: iRegr (20ms); DA (50ms); TSR (20s); Casc (13s); and iCasc (24s).
			% numToUse=40
			%	Pretty bad: DA, TSR.
			%	Single outlier: PCA6.
			%	Best: iPCA, AE, iAE, Casc (nh 1 and 6), and iCasc. iCasc beats Casc.
			%	None of the best are identical, but they are effectively indistinguishable at 99 iterations.
			%	Runtimes: iPCA (30ms), AE (0.8s), Casc (4s), and iCasc (7s).
			algs = [
				struct('func', @fillCCA, 'name', 'CCA', 'args', struct());
				struct('func', @fillNaive, 'name', 'Mean', 'args', struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 2, 'length', 2, 'zmuv', true));
				struct('func', @fillTSR, 'name', 'TSR', 'args', struct('k', sizeX));
				struct('func', @fillPCA, 'name', 'PCA', 'args', struct('k', 6, 'VariableWeights', 'variance'));
				struct('func', @fillIterate, 'name', 'iPCA', 'args', struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 7, 'VariableWeights', 'variance', 'algorithm', 'eig')));
				struct('func', @fillAutoencoder, 'name', 'AE', 'args', struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean', 'zmuv', true));
				struct('func', @fillIterate, 'name', 'iAE', 'args', struct('method', @fillAutoencoder, 'handleNaN', 'mean', 'iterations', 5, 'zmuv', true, 'args', struct('nh', 6, 'trainMissingRows', true)));
				struct('func', @fillRegr, 'name', 'Regr', 'args', struct('handleNaN', 'mean'));
				struct('func', @fillIterate, 'name', 'iRegr', 'args', struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
				struct('func', @fillCascadeAuto, 'name', 'Casc', 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500, 'zmuv', true));
				struct('func', @fillIterate, 'name', 'iCasc', 'args', struct('method', @fillCascadeAuto, 'iterations', 5, 'zmuv', true, 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)));
			];
		case 'PCA'
			% For numToUse=40 and iters=14 with 3 different seeds:
			%	* k>20 results in very large errors. The minimum error appears to be around 1<k<13, though there's not much difference in that range. At k=4 there is an odd jump in runtimes.
			%	* Errors were all 2-3x higher than the first test. Runtime was lowest for 1 and 16, with maximums at 10 and 19.
			%	* Errors between the previous two, again lowest approximately around 7 (u-shaped function of k). Runtime was lowest at 1, 7, 19; highest at 4 and especially 13.
			% For numToUse=277 (all) and iters=14 with 3 different seeds:
			%	* Results are similar to above, but optimal error might be closer to 13-16. (Error magnitude is obviously lower.) Runtime is lowest at 1, 4, 13; highest at 4, 7, and especially 16+.
			% 	* Values are minimal at 10 and rise on either side (barely). Runtimes peak at 7 and fall off to either side.
			% 	* Values are lowest at 7 or 16, roughly U with a middle bump. Runtimes peak at 7 and 16 and are minimal everywhere else.
			algs = [];
			for i=1:3:21
				algs = [algs; struct('func', @fillPCA, 'name', sprintf('P%02d', i), 'args', struct('k', i, 'VariableWeights', 'variance'));];
			end
		case 'TSR'
			algs = [];
			for k=1:3:sizeX
				for con=[1e-10 1e-7 1e-4]
					algs = [algs; struct('func', @fillTSR, 'name', sprintf('T%02d', i), 'args', struct('k', k, 'conv', con));];
				end
			end
		case 'AE'
			algs = [];
			for i=1:sizeX
				algs = [algs; struct('func', @fillAutoencoder, 'name', sprintf('A%02d', i), 'args', struct('nh', i, 'trainMissingRows', true, 'handleNaN', 'mean'));];
			end
		case 'cascade'
			% For numToUse=40, it appears that C01 performs much better than Casc8, 15, 22, and 29. (They get worse with higher nh.) 1 is also better than 2-7.
			% However, iCasc performance is independent of nh. iCasc with 2 iterations is better than 7 iterations.
			% This is also true for numToUse=0 (i.e. 277), tested nh=1-8 and iter=1,2.

			% Once ZMUV is turned on, results are very different...
			% For numToUse=40, increasing from 1 to 8 causes improvements, and 5 iterations is better than 1.
			% When I'm an idiot and forget to actually set nh, for 2 iterations and ZMUV(C), it appears performance is independent of nh (tested at [6, 11, 16, 21] and also at [1, 16, 31]). The data points appear at the *exact* same spots (p=NaN).
			% ZMUV performs slightly better than ZMUV(C).
			% 3 iterations might do slightly better than 2 iterations in rare cases, but usually there is NO change. Likewise 7.
			% nh 4 through 9 are practically identical.
			algs = [];
			for i=6
				algs = [algs; struct('func', @fillCascadeAuto, 'name', sprintf('C%02d', i), 'args', struct('nh', i, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500));];
				algs = [algs; struct('func', @fillIterate, 'name', sprintf('i1C%02dk', i), 'args', struct('method', @fillCascadeAuto, 'iterations', 3, 'args', struct('nh', i, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 1000)))];
				algs = [algs; struct('func', @fillIterate, 'name', sprintf('i2C%02d', i), 'args', struct('method', @fillCascadeAuto, 'iterations', 7, 'args', struct('nh', i, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)))];
			end
			len = length(algs);
			a2 = [];
			for i=1:len
				al = algs(i);
				% b = struct();
				% for fn = fieldnames(al)'
				% 	b.(fn{1}) = al.(fn{1});
				% end
				% b.args.zmuvFromComplete = true;
				% b.name = char(strcat(b.name, " ZMC"));
				% a2 = [a2; b];
				b = struct();
				for fn = fieldnames(al)'
					b.(fn{1}) = al.(fn{1});
				end
				b.args.zmuv = true;
				% b.name = char(strcat(b.name, " ZM"));
				a2 = [a2; b];
			end
			algs = a2;
		case 'DA'
			% For numToUse=277 (all), number=1 gives NaN. Otherwise, performance is COMPLETELY insensitive to these parameters, except length=1 is a bit worse.
			% I also tested missmiss('DA', 'parallelize', true, 'iters', 140, 'fixedSeed', false, 'numToUse', 100). It gave similar results.
			% Conclusion: pick number=2 and length=2 for speed.
			algs = [
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 2, 'length', 2));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 5, 'length', 5));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 5, 'length', 50));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 10, 'length', 50));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 20, 'length', 50));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 50, 'length', 50));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 5, 'length', 100));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 10, 'length', 100));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 20, 'length', 100));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 50, 'length', 100));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 5, 'length', 200));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 10, 'length', 200));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 20, 'length', 200));
				struct('func', @fillDA, 'name', 'DA', 'args', struct('number', 50, 'length', 200));
			];
		otherwise
			error("No algorithm list name was provided.")
	end
end
