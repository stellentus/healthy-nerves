%% batcher detects batch effects.
function [canValues, legValues, japValues, porValues, measures, cri, normMutual] = batcher()
	nanMethod = 'IterateRegr';

	% Load the data
	addpath import;
	[canValues, canParticipants, canMeasures] = mefimport('data/human/MedianRepeatedMeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all median, not just repeated
	[legValues, legParticipants, legMeasures] = mefimport('data/human/CPrepeatedmeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all CP, not just repeated
	[japValues, japParticipants, japMeasures] = importAllXLSX('none', 'data/Japan');
	[porValues, porParticipants, porMeasures] = importAllXLSX('none', 'data/Portugal');
	rmpath import;

	% Ensure all datasets have the desired measures
	assert(isequal(canMeasures, legMeasures), 'Canadian arm and leg measures are not the same');
	assert(isequal(canMeasures, japMeasures), 'Canadian and Japanese measures are not the same');
	assert(isequal(canMeasures, porMeasures), 'Canadian and Portuguese measures are not the same');
	measures = canMeasures;
	clear legMeasures japMeasures porMeasures;

	% Flatten Japanese and Portuguese data
	[japValues, japParticipants] = flattenStructs(japValues, japParticipants);
	[porValues, porParticipants] = flattenStructs(porValues, porParticipants);

	% Delete people who have no sex
	[canValues, canParticipants] = deleteNoSex(canValues, canParticipants);
	[japValues, japParticipants] = deleteNoSex(japValues, japParticipants);
	[porValues, porParticipants] = deleteNoSex(porValues, porParticipants);

	% Fill missing data
	addpath missing;
	canValues = fillWithMethod(canValues, nanMethod, true);
	legValues = fillWithMethod(legValues, nanMethod, true);
	japValues = fillWithMethod(japValues, nanMethod, true);
	porValues = fillWithMethod(porValues, nanMethod, true);
	rmpath missing;

	% Get and print count of each group and age range
	canNum = size(canValues, 1);
	japNum = size(japValues, 1);
	porNum = size(porValues, 1);
	canMale = countMales(canValues);
	japMale = countMales(japValues);
	porMale = countMales(porValues);
	[canMin, canMax] = ageRange(canValues);
	[japMin, japMax] = ageRange(japValues);
	[porMin, porMax] = ageRange(porValues);
	fprintf('There are %d participants from Canada (%d male) ages %d to %d.\n', canNum, canMale, canMin, canMax);
	fprintf('There are %d participants from Japan (%d male) ages %d to %d.\n', japNum, japMale, japMin, japMax);
	fprintf('There are %d participants from Portugal (%d male) ages %d to %d.\n', porNum, porMale, porMin, porMax);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	% Calculate and print measures of batching
	cri = [];
	normMutual = [];
	randCri = [];
	randNormMutual = [];
	batchCri = [];
	batchNormMutual = [];
	for i=1:30
		[c, n] = calculateBatchResults(labels, kmeans(values, 3));
		cri = [cri c];
		normMutual = [normMutual n];

		randLabels = randi([1 3], 1, length(labels));

		[c, n] = calculateBatchResults(randLabels, kmeans(values, 3));
		randCri = [randCri c];
		randNormMutual = [randNormMutual n];

		[c, n] = calculateBatchResults(randLabels, randLabels);
		batchCri = [batchCri c];
		batchNormMutual = [batchNormMutual n];
	end

	printBatchResults(cri, normMutual, 'k-means');
	printBatchResults(randCri, randNormMutual, 'k-means (random)');
	printBatchResults(batchCri, batchNormMutual, 'batched');
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

function [vals, parts] = deleteNoSex(vals, parts)
	hasSex = ismember(vals(:, 15), [2.0 1.0]);
	fprintf('Deleting sexless %s.\n', parts(~hasSex));
	vals = vals(hasSex, :);
	parts = parts(hasSex);
end

function [males] = countMales(vals)
	males = sum(ismember(vals(:, 15), [1.0]));
end

function [minAge, maxAge] = ageRange(vals)
	minAge = min(vals(:, 14));
	maxAge = max(vals(:, 14));
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

function [dedupVals, dedupParts] = deduplicate(vals, parts)
	[~, indices] = unique(parts, 'first');
	dedupParts = parts(sort(indices));
	dedupVals = vals(sort(indices), :);
end
