%% batcher detects batch effects.
function [canValues, legValues, japValues, porValues, measures, cri, normMutual] = batcher()
	nanMethod = 'IterateRegr';
	addpath import;
	[canValues, canParticipants, japValues, japParticipants, porValues, porParticipants, measures, legValues, legParticipants] = importDatasets('data/', nanMethod);
	rmpath import;

	save('bin/batch-normative.mat', 'canValues', 'canParticipants', 'japValues', 'japParticipants', 'porValues', 'porParticipants', 'measures', 'nanMethod')

	% Get and print count of each group and age range
	canNum = printStats(canValues, 'Canada');
	japNum = printStats(japValues, 'Japan');
	porNum = printStats(porValues, 'Portugal');
	legNum = printStats(legValues, 'Legs');

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	% Calculate and print measures of batching
	cri = [];
	normMutual = [];
	criNoCan = [];
	normMutualNoCan = [];
	criNoJap = [];
	normMutualNoJap = [];
	criNoPor = [];
	normMutualNoPor = [];
	randCri = [];
	randNormMutual = [];
	batchCri = [];
	batchNormMutual = [];
	legCri = [];
	legNormMutual = [];
	for i=1:30
		[c, n] = calculateBatchResults(labels, kmeans(values, 3));
		cri = [cri c];
		normMutual = [normMutual n];

		[c, n] = calculateBatchResults([ones(japNum, 1); ones(porNum, 1) * 2], kmeans([japValues; porValues], 2));
		criNoCan = [criNoCan c];
		normMutualNoCan = [normMutualNoCan n];

		[c, n] = calculateBatchResults([ones(canNum, 1); ones(porNum, 1) * 2], kmeans([canValues; porValues], 2));
		criNoJap = [criNoJap c];
		normMutualNoJap = [normMutualNoJap n];

		[c, n] = calculateBatchResults([ones(canNum, 1); ones(japNum, 1) * 2], kmeans([canValues; japValues], 2));
		criNoPor = [criNoPor c];
		normMutualNoPor = [normMutualNoPor n];

		randLabels = randi([1 3], 1, length(labels));

		[c, n] = calculateBatchResults(randLabels, kmeans(values, 3));
		randCri = [randCri c];
		randNormMutual = [randNormMutual n];

		[c, n] = calculateBatchResults(randLabels, randLabels);
		batchCri = [batchCri c];
		batchNormMutual = [batchNormMutual n];

		[c, n] = calculateBatchResults([ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], kmeans([legValues; japValues; porValues], 3));
		legCri = [legCri c];
		legNormMutual = [legNormMutual n];
	end

	printBatchResults(cri, normMutual, 'k-means');
	printBatchResults(criNoCan, normMutualNoCan, 'k-means (No Canada)');
	printBatchResults(criNoJap, normMutualNoJap, 'k-means (No Japan)');
	printBatchResults(criNoPor, normMutualNoPor, 'k-means (No Portugal)');
	printBatchResults(randCri, randNormMutual, 'k-means (random)');
	printBatchResults(batchCri, batchNormMutual, 'batched');
	printBatchResults(legCri, legNormMutual, 'k-means (Canadian legs)');
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
	fprintf('The adjusted rand index for %s is %.4f%c%.4f.\n', str, mean(cri), char(177), std(cri));
	fprintf('The normalized mutual information for %s is %.4f%c%.4f.\n', str, mean(normMutual), char(177), std(normMutual));
end

function [num] = printStats(vals, str)
	num = size(vals, 1);
	male = countMales(vals);
	[ageMin, ageMax] = ageRange(vals);
	fprintf('There are %d participants from %s (%d male) ages %d to %d.\n', num, str, male, ageMin, ageMax);
end

function [males] = countMales(vals)
	males = sum(ismember(vals(:, 15), [1.0]));
end

function [minAge, maxAge] = ageRange(vals)
	minAge = min(vals(:, 14));
	maxAge = max(vals(:, 14));
end

function [dedupVals, dedupParts] = deduplicate(vals, parts)
	[~, indices] = unique(parts, 'first');
	dedupParts = parts(sort(indices));
	dedupVals = vals(sort(indices), :);
end
