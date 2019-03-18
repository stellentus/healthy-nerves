%% batcher detects batch effects.
function bas = batcher(varargin)
	p = inputParser;
	addOptional(p, 'action', "stats", @(x) any(validatestring(x, {'stats', 'age', 'misc', 'var', 'mean', 'del', 'hill'})));
	addParameter(p, 'iter', 5, @isnumeric);
	addParameter(p, 'sampleFraction', -1, @isnumeric);
	addParameter(p, 'printAsCSV', true, @islogical);
	addParameter(p, 'plotImportantIndices', false, @islogical); % This only works with 'action'=='del'
	addParameter(p, 'args', struct(), @isstruct); % Passed to other functions; not always used
	addParameter(p, 'printPercent', 100, @(x) isnumeric(x) && x>0 && x<=100); % Percent of results to print
	addParameter(p, 'sortStat', "CRI", @(x) any(validatestring(x, {'CRI', 'NMI', 'HEL'})));
	addParameter(p, 'sortOrder', "ascend", @(x) any(validatestring(x, {'ascend', 'descend'})));
	addParameter(p, 'sort', false, @islogical);
	addParameter(p, 'plotBoxes', false, @islogical);
	addParameter(p, 'file', "bin/batch-normative.mat", @isstring);
	parse(p, varargin{:});

	addpath batches;

	sampleFraction = p.Results.sampleFraction;
	if sampleFraction < 0 || sampleFraction > 1
		sampleFraction = 1/p.Results.iter;
	end

	switch p.Results.action
		case "stats"
			printStats(p.Results.file);
			bas = []; % Not used
			return;
		case "age"
			bas = getAgeMatchedBatches(p.Results.iter, sampleFraction, p.Results.file);
		case "misc"
			bas = getMiscSeekerBatches(p.Results.iter, sampleFraction, p.Results.file);
		case "var"
			bas = getVarSeekerBatches(p.Results.iter, sampleFraction, p.Results.file);
		case "mean"
			bas = getMeanSeekerBatches(p.Results.iter, sampleFraction, p.Results.file);
		case "del"
			bas = getDeletedFeatureBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.args);
		case "hill"
			getHillClimberBatches(p.Results.iter, sampleFraction, p.Results.file);
			bas = []; % Not used
			return;
		otherwise
			error(sprintf("%s is an invalid argument to batcher", p.Results.action));
			bas = []; % Not used
			return;
	end

	% Calculate BE and print
	for i = 1:length(bas)
		ba = bas(i);
		calculateBatch(ba);
	end

	if p.Results.printPercent < 100
		maxIndex = round(length(bas)*p.Results.printPercent/100);
	else
		maxIndex = length(bas);
	end

	if p.Results.printPercent < 100 || p.Results.sort == true
		if strcmp(p.Results.sortStat, "HEL")
			[~, ind] = sort([bas.HEL_mean]);
		elseif strcmp(p.Results.sortStat, "CRI")
			[~, ind] = sort(abs([bas.CRI_mean]));
		else
			[~, ind] = sort([bas.NMI_mean]);
		end
		if strcmp(p.Results.sortOrder, "descend")
			ind = fliplr(ind);
		end

		printBas = bas(ind(1:maxIndex));
	else
		printBas = bas;
	end

	padLen = printHeader(printBas, p.Results.printAsCSV);
	scores = zeros(p.Results.iter, maxIndex); % only used by plotBoxes
	for i = 1:maxIndex
		disp(BAString(printBas(i), padLen, p.Results.printAsCSV));
		scores(:, i) = (printBas(i).NMI');
	end

	if p.Results.printPercent < 100
		% Now print the mean values for a reference point
		meanBA = BatchAnalyzer("Means", 3, []);
		meanBA.HEL_mean = mean([bas.HEL_mean]);
		meanBA.HEL_std = mean([bas.HEL_std]);
		meanBA.CRI_mean = mean([bas.CRI_mean]);
		meanBA.CRI_std = mean([bas.CRI_std]);
		meanBA.NMI_mean = mean([bas.NMI_mean]);
		meanBA.NMI_std = mean([bas.NMI_std]);
		disp(BAString(meanBA, padLen, p.Results.printAsCSV));
	end

	if p.Results.plotImportantIndices
		load(p.Results.file);
		plotImportantIndices(printBas, measures);
	end

	if p.Results.plotBoxes
		plotBoxes(scores, [printBas.Name]');
	end

	rmpath batches;
end

function padLen = printHeader(bas, printAsCSV)
	% Get length of longest string for padding purposes
	padLen = 0;
	for i = 1:length(bas)
		slen = strlength(bas(i).Name);
		if slen > padLen
			padLen = slen;
		end
	end

	% Print the table header
	if printAsCSV
		fprintf('%s , HEL    ,HELstd , CRI    ,CRIstd , NMI    ,NMIstd \n', pad("Name", padLen));
		fprintf('%s , ------ , ----- , ------ , ----- , ------ , ----- \n', strrep(pad(" ", padLen), " ", "-"));
	else
		fprintf('%s |  HEL (std)     |  CRI (std)     |  NMI (std)     \n', pad("Name", padLen));
		fprintf('%s | -------------- | -------------- | -------------- \n', strrep(pad(" ", padLen), " ", "-"));
	end
end

function plotBoxes(scores, testNames)
	addpath lib/CategoricalScatterplot

	pathstr = sprintf('img/batbox-%d-%d-%d-%d%d%2.0f', clock);

	fig = figure('DefaultAxesFontSize', 18);

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29);
	title('Batch Effect Measures');
	xlabel('Group');
	ylabel('NMI');
	xtickangle(45)
	savefig(fig, strcat(pathstr, '.fig', 'compact'));
	saveas(fig, strcat(pathstr, '.png'));

	rmpath lib/CategoricalScatterplot
end
