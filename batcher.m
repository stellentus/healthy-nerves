%% batcher detects batch effects.
function [canValues, legValues, japValues, porValues, measures, cri, normMutual] = batcher()
	nanMethod = 'IterateRegr';

	% Load the data
	addpath import;
	[canValues, ~, canMeasures] = mefimport('data/human/MedianRepeatedMeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all median, not just repeated
	[legValues, ~, legMeasures] = mefimport('data/human/CPrepeatedmeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all CP, not just repeated
	[japValues, ~, japMeasures] = importAllXLSX('none', 'data/Japan');
	[porValues, ~, porMeasures] = importAllXLSX('none', 'data/Portugal');
	rmpath import;

	% Ensure all datasets have the desired measures
	assert(isequal(canMeasures, legMeasures), 'Canadian arm and leg measures are not the same');
	assert(isequal(canMeasures, japMeasures), 'Canadian and Japanese measures are not the same');
	assert(isequal(canMeasures, porMeasures), 'Canadian and Portuguese measures are not the same');
	measures = canMeasures;
	clear legMeasures japMeasures porMeasures;

	% Flatten Japanese and Portuguese data
	[japValues] = flattenStruct(japValues);
	[porValues] = flattenStruct(porValues);

	% Fill missing data
	addpath missing;
	canValues = fillWithMethod(canValues, nanMethod, true);
	legValues = fillWithMethod(legValues, nanMethod, true);
	japValues = fillWithMethod(japValues, nanMethod, true);
	porValues = fillWithMethod(porValues, nanMethod, true);
	rmpath missing;

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];
	values = [canValues; japValues; porValues];

	% Calculate and print measures of batching
	cri = [];
	normMutual = [];
	randCri = [];
	randNormMutual = [];
	for i=1:30
		[c, n] = calculateBatchResults(labels, kmeans(values, 3));
		cri = [cri c];
		normMutual = [normMutual n];
		[c, n] = calculateBatchResults(randi([1 3], 1, length(labels)), kmeans(values, 3));
		randCri = [randCri c];
		randNormMutual = [randNormMutual n];
	end

	printBatchResults(cri, normMutual, 'k-means');
	printBatchResults(randCri, randNormMutual, 'k-means (random)');
end

function [cri, norm_mutual] = calculateBatchResults(labels, idx)
	% Calculate corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
	cri = rand_index(labels, idx, 'adjusted');

	% Calculate the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
	addpath info_entropy;
	norm_mutual = nmi(labels, idx);
	rmpath info_entropy;
end

function [] = printBatchResults(cri, normMutual, str)
	% char(177) is the plus/minus symbol
	fprintf('The adjusted rand index for %s is %.3f%c%.3f.\n', str, mean(cri), char(177), std(cri));
	fprintf('The normalized mutual information for %s is %.3f%c%.3f.\n', str, mean(normMutual), char(177), std(normMutual));
end

function [flatVals] = flattenStruct(structVals)
	flatVals = [];
	fields = fieldnames(structVals);
	for i = 1:numel(fields)
		flatVals = [flatVals; structVals.(fields{i})];
	end
end

function [dedupVals, dedupParts] = deduplicate(vals, parts)
	[~, indices] = unique(parts, 'first');
	dedupParts = parts(sort(indices));
	dedupVals = vals(sort(indices), :);
end
