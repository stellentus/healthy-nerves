%% batcher detects batch effects.
function batcher(varargin)
	p = inputParser;
	addOptional(p, 'action', "stats", @(x) any(validatestring(x, {'stats', 'misc', 'var', 'mean', 'del', 'hill'})));
	addParameter(p, 'iter', 30, @isnumeric);
	addParameter(p, 'printAsCSV', true, @islogical);
	addParameter(p, 'args', struct(), @isstruct); % Passed to other functions; not always used
	parse(p, varargin{:});

	addpath batches;

	switch p.Results.action
		case "stats"
			printStats();
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
			return;
		otherwise
			error(sprintf("%s is an invalid argument to batcher", p.Results.action));
			return;
	end

	num = length(bas);
	str = strings(1,num);
	cri_mean = zeros(1,num);
	cri_std = zeros(1,num);
	nmi_mean = zeros(1,num);
	nmi_std = zeros(1,num);

	% Get length of longest string for padding purposes
	padLen = 0;
	for i = 1:num
		slen = strlength(bas(i).Name);
		if slen > padLen
			padLen = slen;
		end
	end

	% Print the table header
	if p.Results.printAsCSV
		printHeaderCSV(padLen);
	else
		printHeader(padLen);
	end

	% Calculate BE and print
	for i = 1:num
		ba = bas(i);
		calculateBatch(ba);
		disp(BAString(ba, padLen, p.Results.printAsCSV));
	end

	rmpath batches;
end

function printHeader(padLen)
	fprintf('%s |  CRI (std)     |  NMI (std)     \n', pad("Name", padLen));
	fprintf('%s | -------------- | -------------- \n', strrep(pad(" ", padLen), " ", "-"));
end

function printHeaderCSV(padLen)
	fprintf('%s , CRI    ,CRIstd , NMI    ,NMIstd \n', pad("Name", padLen));
	fprintf('%s , ------ , ----- , ------ , ----- \n', strrep(pad(" ", padLen), " ", "-"));
end
