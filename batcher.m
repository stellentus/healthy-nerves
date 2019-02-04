%% batcher detects batch effects.
function [canValues, legValues, japValues, porValues, measures, cri, normMutual] = batcher()
	load('bin/batch-normative.mat');

	% Get and print count of each group and age range
	canNum = printStats(canValues, 'Canada');
	japNum = printStats(japValues, 'Japan');
	porNum = printStats(porValues, 'Portugal');
	legNum = printStats(legValues, 'Legs');

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	% Calculate and print measures of batching
	iters = 30;
	rng('shuffle');
	scurr = rng(); % Ensure all start with the same seed

	[cri, normMutual] = calculateBatchResults(iters, scurr.Seed, 3, values, labels);
	[criNoCan, normMutualNoCan] = calculateBatchResults(iters, scurr.Seed, 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2]);
	[criNoJap, normMutualNoJap] = calculateBatchResults(iters, scurr.Seed, 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2]);
	[criNoPor, normMutualNoPor] = calculateBatchResults(iters, scurr.Seed, 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2]);

	[randCri, randNormMutual] = calculateBatchResults(iters, scurr.Seed, 3, values);
	[batchCri, batchNormMutual] = calculateBatchResults(iters, scurr.Seed, 3, length(labels)); % Instead of passing any data at all, request both arrays to be identical random indices.
	[legCri, legNormMutual] = calculateBatchResults(iters, scurr.Seed, 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)]);

	printBatchResults(cri, normMutual, 'k-means');
	printBatchResults(criNoCan, normMutualNoCan, 'k-means (No Canada)');
	printBatchResults(criNoJap, normMutualNoJap, 'k-means (No Japan)');
	printBatchResults(criNoPor, normMutualNoPor, 'k-means (No Portugal)');
	printBatchResults(randCri, randNormMutual, 'k-means (random)');
	printBatchResults(batchCri, batchNormMutual, 'batched');
	printBatchResults(legCri, legNormMutual, 'k-means (Canadian legs)');
end

% calculateBatchResults will repeatedly calculate batch results with
function [cri, norm_mutual] = calculateBatchResults(iters, seed, numGroups, values, labels)
	cri = [];
	norm_mutual = [];
	rng(seed); % Ensure all start with the same seed

	% If there's only one value that means 'values' is instead an integer length of random indices.
	randomIndices = (numel(values) == 1);

	addpath info_entropy;
	for i=1:iters
		% Create the clustered groups
		if randomIndices
			idx = randi([1 numGroups], 1, values);
			if nargin < 5
				labels = idx;
			end
		else
			idx = kmeans(values, numGroups);
			if nargin < 5
				labels = randi([1 numGroups], 1, length(values));
			end
		end

		% Calculate and append corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
		cri = [cri rand_index(labels, idx, 'adjusted')];

		% Calculate and append the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
		norm_mutual = [norm_mutual nmi(labels, idx)];
	end
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
