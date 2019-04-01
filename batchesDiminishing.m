% batchesDiminishing plots a figure with increasing sample size. Does it converge?
function batchesDiminishing(figToPlot)
	iters = 30;
	sampleFraction = 0.8;

	% Load the data
	[canValues, japValues, porValues] = loadNorm();

	[values, labels] = fillAndCombine(canValues, japValues, porValues, 'IterateRegr');
	[valuesMean, labelsMean] = fillAndCombine(canValues, japValues, porValues, 'Mean');
	[valuesZeroed, labelsZeroed] = fillAndCombine(canValues, japValues, porValues, 'Zero');
	[valuesCCA, labelsCCA] = fillAndCombine(canValues, japValues, porValues, 'CCA');

	addpath batches;

	bas = [
		sampledData(values, labels, 0.1, iters, sampleFraction);
		sampledData(values, labels, 0.2, iters, sampleFraction);
		sampledData(values, labels, 0.3, iters, sampleFraction);
		sampledData(values, labels, 0.4, iters, sampleFraction);
		sampledData(values, labels, 0.5, iters, sampleFraction);
		sampledData(values, labels, 0.6, iters, sampleFraction);
		sampledData(values, labels, 0.7, iters, sampleFraction);
		sampledData(values, labels, 0.8, iters, sampleFraction);
		sampledData(values, labels, 0.9, iters, sampleFraction);
		BatchAnalyzer(sprintf("Filled Data (%d)", length(labels)), 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer(sprintf("CCA Data (%d)", length(labelsCCA)), 3, valuesCCA, labelsCCA, 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer(sprintf("Mean Data (%d)", length(labelsMean)), 3, valuesMean, labelsMean, 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer(sprintf("Zeroed Data (%d)", length(labelsZeroed)), 3, valuesZeroed, labelsZeroed, 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Random Labels", 3, size(values, 1), labels, 'iters', iters, 'sampleFraction', sampleFraction);
	];
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-norm-sample-size', 'Normative Data at Various Sample Sizes');

	rmpath batches;
end

function [canValues, japValues, porValues] = loadNorm()
	% Load the data
	addpath import;
	[canValues, canParticipants] = mefimport('data/human/FESmedianAPB_Concatenated.xlsx', false, false, canonicalNamesNoTE20());
	[japValues, japParticipants] = importAllXLSX('none', 'data/Japan');
	[porValues, porParticipants] = importAllXLSX('none', 'data/Portugal');
	rmpath import;

	% Flatten Japanese and Portuguese data
	[japValues, japParticipants] = flattenStructs(japValues, japParticipants);
	[porValues, porParticipants] = flattenStructs(porValues, porParticipants);

	% Delete people who have no sex
	[canValues, canParticipants] = deleteNoSex(canValues, canParticipants);
	[japValues, japParticipants] = deleteNoSex(japValues, japParticipants);
	[porValues, porParticipants] = deleteNoSex(porValues, porParticipants);

	% Delete duplicate records
	canValues = deduplicate(canValues, canParticipants);
	japValues = deduplicate(japValues, japParticipants);
	porValues = deduplicate(porValues, porParticipants);
end

function [values, labels] = fillAndCombine(canValues, japValues, porValues, nanMethod)
	% Fill missing data
	addpath missing;
	canValues = fillWithMethod(canValues, nanMethod, true);
	japValues = fillWithMethod(japValues, nanMethod, true);
	porValues = fillWithMethod(porValues, nanMethod, true);
	rmpath missing;

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];
	values = [canValues; japValues; porValues];
end

function [flatVals, flatParts] = flattenStructs(structVals, structParts)
	flatVals = [];
	flatParts = [];
	fields = fieldnames(structVals);
	for i = 1:numel(fields)
		thisParts = structParts.(fields{i});
		thisVals = structVals.(fields{i});
		for j = 1:length(thisParts)
			% Only add the data if the participant hasn't already been added
			if length(flatParts) < 2 || sum(ismember(flatParts, thisParts(j))) == 0
				flatVals = [flatVals; thisVals(j, :)];
				flatParts = [flatParts; thisParts(j)];
			end
		end
	end
end

function [vals, parts] = deleteNoSex(vals, parts)
	hasSex = ismember(vals(:, 15), [2.0 1.0]);
	if sum(~hasSex) > 0
		fprintf('Deleting sexless %s.\n', parts(~hasSex));
	end
	vals = vals(hasSex, :);
	parts = parts(hasSex);
end

function [dedupVals, dedupParts] = deduplicate(vals, parts)
	orig = length(parts);
	[~, indices] = unique(parts, 'first');
	dedupParts = parts(sort(indices));
	dedupVals = vals(sort(indices), :);
	if length(dedupParts) ~= orig
		fprintf('Deleted %d duplicates\n', orig-length(dedupParts));
	end
end

function bas = sampledData(values, labels, thisFrac, iters, sampleFraction)
	origLen = length(labels);
	newLen = round(thisFrac*origLen);

	inds = randperm(origLen);
	inds = inds(1:newLen);

	str = sprintf("Sample %.0f%% (%d)", thisFrac*100, newLen);

	bas = BatchAnalyzer(str, 3, values(inds, :), labels(inds), 'iters', iters, 'sampleFraction', sampleFraction);
end
