%% batcher detects batch effects.
function bas = batcher(varargin)
	p = inputParser;
	addOptional(p, 'action', "stats", @(x) any(validatestring(x, {'stats', 'misc', 'var', 'mean', 'del', 'hill'})));
	addParameter(p, 'iter', 30, @isnumeric);
	addParameter(p, 'printAsCSV', true, @islogical);
	addParameter(p, 'args', struct(), @isstruct); % Passed to other functions; not always used
	addParameter(p, 'printPercent', 100, @(x) isnumeric(x) && x>0 && x<=100); % Percent of results to print
	addParameter(p, 'sortStat', "CRI", @(x) any(validatestring(x, {'CRI', 'NMI'})));
	addParameter(p, 'sortOrder', "ascend", @(x) any(validatestring(x, {'ascend', 'descend'})));
	parse(p, varargin{:});

	addpath batches;

	switch p.Results.action
		case "stats"
			printStats();
			bas = []; % Not used
			return;
		case "misc"
			bas = getMiscSeekerBatches(p.Results.iter);
		case "var"
			bas = getVarSeekerBatches(p.Results.iter);
		case "mean"
			bas = getMeanSeekerBatches(p.Results.iter);
		case "del"
			bas = getDeletedFeatureBatches(p.Results.iter, p.Results.args);
		case "hill"
			getHillClimberBatches(p.Results.iter);
			bas = []; % Not used
			return;
		otherwise
			error(sprintf("%s is an invalid argument to batcher", p.Results.action));
			bas = []; % Not used
			return;
	end

	if p.Results.printPercent == 100
		padLen = printHeader(bas, p.Results.printAsCSV);
	end

	% Calculate BE and print
	for i = 1:length(bas)
		ba = bas(i);
		calculateBatch(ba);
		if p.Results.printPercent == 100
			disp(BAString(ba, padLen, p.Results.printAsCSV));
		end
	end

	if p.Results.printPercent < 100
		if strcmp(p.Results.sortStat, "CRI")
			[~, ind] = sort([bas.CRI_mean]);
		else
			[~, ind] = sort([bas.NMI_mean]);
		end
		if strcmp(p.Results.sortOrder, "descend")
			ind = fliplr(ind);
		end

		maxIndex = round(length(bas)*p.Results.printPercent/100);
		sortedBas = bas(ind(1:maxIndex));

		padLen = printHeader(sortedBas, p.Results.printAsCSV);
		for i=1:maxIndex
			disp(BAString(sortedBas(i), padLen, p.Results.printAsCSV));
		end

		% Now print the mean values for a reference point
		meanBA = BatchAnalyzer("Means", 3, []);
		meanBA.CRI_mean = mean([bas.CRI_mean]);
		meanBA.CRI_std = mean([bas.CRI_std]);
		meanBA.NMI_mean = mean([bas.NMI_mean]);
		meanBA.NMI_std = mean([bas.NMI_std]);
		disp(BAString(meanBA, padLen, p.Results.printAsCSV));
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
		fprintf('%s , CRI    ,CRIstd , NMI    ,NMIstd \n', pad("Name", padLen));
		fprintf('%s , ------ , ----- , ------ , ----- \n', strrep(pad(" ", padLen), " ", "-"));
	else
		fprintf('%s |  CRI (std)     |  NMI (std)     \n', pad("Name", padLen));
		fprintf('%s | -------------- | -------------- \n', strrep(pad(" ", padLen), " ", "-"));
	end
end
