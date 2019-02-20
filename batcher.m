%% batcher detects batch effects.
function batcher(varargin)
	p = inputParser;
	addOptional(p, 'action', "stats", @(x) any(validatestring(x, {'stats', 'misc', 'var', 'mean'})));
	addParameter(p, 'iter', 30, @isnumeric);
	addParameter(p, 'printAsCSV', true, @islogical);
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

	for i = 1:num
		ba = bas(i);
		calculateBatch(ba);
		str(i) = ba.Name;
		cri_mean(i) = mean(ba.CRI);
		cri_std(i) = std(ba.CRI);
		nmi_mean(i) = mean(ba.NMI);
		nmi_std(i) = std(ba.NMI);
	end

	rmpath batches;

	if p.Results.printAsCSV
		printBatchResultsCSV(str, cri_mean, cri_std, nmi_mean, nmi_std);
	else
		printBatchResults(str, cri_mean, cri_std, nmi_mean, nmi_std);
	end
end

function printBatchResults(str, cri_mean, cri_std, nmi_mean, nmi_std)
	strs = pad(str);
	fprintf('%s |  CRI (std)     |  NMI (std)     \n', pad("Name", strlength(strs(1))));
	fprintf('%s | -------------- | -------------- \n', strrep(pad(" ", strlength(strs(1))), " ", "-"));
	for i=1:length(strs)
		fprintf('%s | % .3f (%.3f) | % .3f (%.3f) \n', strs(i), cri_mean(i), cri_std(i), nmi_mean(i), nmi_std(i));
	end
end

function printBatchResultsCSV(str, cri_mean, cri_std, nmi_mean, nmi_std)
	strs = pad(str);
	fprintf('%s ,  CRI , CRIstd  ,  NMI , NMIstd  \n', pad("Name", strlength(strs(1))));
	fprintf('%s , -----,-------- , -----,-------- \n', strrep(pad(" ", strlength(strs(1))), " ", "-"));
	for i=1:length(strs)
		fprintf('%s , % .3f , %.3f , % .3f , %.3f \n', strs(i), cri_mean(i), cri_std(i), nmi_mean(i), nmi_std(i));
	end
end
