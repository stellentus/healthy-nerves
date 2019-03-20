%% batcher detects batch effects.
function bas = batcher(varargin)
	p = inputParser;
	addOptional(p, 'action', "misc", @(x) any(validatestring(x, {'stats', 'age', 'misc', 'var', 'mean', 'del', 'hill', 'k'})));
	addParameter(p, 'iter', 30, @isnumeric);
	addParameter(p, 'sampleFraction', 0.8, @isnumeric);
	addParameter(p, 'plotImportantIndices', false, @islogical); % This only works with 'action'=='del'
	addParameter(p, 'args', struct(), @isstruct); % Passed to other functions; not always used
	addParameter(p, 'printPercent', 100, @(x) isnumeric(x) && x>0 && x<=100); % Percent of results to print
	addParameter(p, 'sortStat', "NMI", @(x) any(validatestring(x, {'CRI', 'NMI', 'HEL'})));
	addParameter(p, 'sortOrder', "ascend", @(x) any(validatestring(x, {'ascend', 'descend'})));
	addParameter(p, 'sort', false, @islogical);
	addParameter(p, 'plotBoxes', true, @islogical);
	addParameter(p, 'printHell', false, @islogical);
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
			bas = getAgeMatchedBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell);
		case "misc"
			bas = getMiscSeekerBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell);
		case "var"
			bas = getVarSeekerBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell);
		case "mean"
			bas = getMeanSeekerBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell);
		case "k"
			bas = getkSeekerBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell);
		case "del"
			bas = getDeletedFeatureBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell, p.Results.args);
		case "hill"
			getHillClimberBatches(p.Results.iter, sampleFraction, p.Results.file, p.Results.printHell);
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

	plotBas(bas, p.Results);

	if p.Results.plotImportantIndices
		load(p.Results.file);
		plotImportantIndices(printBas, measures);
	end

	rmpath batches;
end
