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

	% Test the normative data
	printBatchResults('the normative data', iters, scurr.Seed, @kmeans, 3, values, labels);

	% Remove each type to see how things change
	% printBatchResults('no Canada', iters, scurr.Seed, @kmeans, 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2]);
	% printBatchResults('no Japan', iters, scurr.Seed, @kmeans, 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2]);
	% printBatchResults('no Portugal', iters, scurr.Seed, @kmeans, 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2]);

	% Confirm that random and perfectly batched data work as expected
	% printBatchResults('random labels', iters, scurr.Seed, @kmeans, 3, values);
	% printBatchResults('batched data', iters, scurr.Seed, @kmeans, 3, length(labels)); % Instead of passing any data at all, request both arrays to be identical random indices.

	% Show larger batches with CP instead of median
	printBatchResults('Canadian legs', iters, scurr.Seed, @kmeans, 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)]);

	% Look at batches when RC is shifted logarithmically in time
	printBatchResults('all shifted RC', iters, scurr.Seed, @kmeans, 3, shiftValues(values), labels);
	printBatchResults('Canada shifted RC', iters, scurr.Seed, @kmeans, 3, [shiftValues(canValues); japValues; porValues], labels);
end

% calculateBatchResults will repeatedly calculate batch results with
function [cri, norm_mutual] = calculateBatchResults(iters, seed, clusterFunc, numGroups, values, labels)
	cri = [];
	norm_mutual = [];
	rng(seed); % Ensure all start with the same seed

	% If there's only one value that means 'values' is instead an integer length of random indices.
	randomIndices = (numel(values) == 1);

	addpath lib/rand_index;
	addpath lib/info_entropy;
	for i=1:iters
		% Create the clustered groups
		if randomIndices
			idx = randi([1 numGroups], 1, values);
			if nargin < 6
				labels = idx;
			end
		else
			idx = clusterFunc(values, numGroups);
			if nargin < 6
				labels = randi([1 numGroups], 1, length(values));
			end
		end

		% Calculate and append corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
		cri = [cri rand_index(labels, idx, 'adjusted')];

		% Calculate and append the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
		norm_mutual = [norm_mutual nmi(labels, idx)];
	end
	rmpath lib/rand_index;
	rmpath lib/info_entropy;
end

function [] = printBatchResults(str, varargin)
	[cri, normMutual] = calculateBatchResults(varargin{:});

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

function [shiftedValues] = shiftValues(vals)
	shiftedValues = vals;
	shiftedValues(:, 9) = shiftedValues(:, 9) * 1.2;  % Shift RRP right by 20%
	shiftedValues(:, 26) = shiftedValues(:, 26) * 1.3;  % Shift Ref@2.5 right by increasing value by 30%.
	shiftedValues(shiftedValues(:, 26)<0, 26) = 0;  % However, this might be <0, so set those to 0.
	shiftedValues(:, 29) = shiftedValues(:, 29) * 1.4;  % Shift Ref@2.0 right by increasing value by 40%
	shiftedValues(:, 30) = shiftedValues(:, 31);  % Shift Super@7 to equal the Super@5 value
	shiftedValues(:, 30) = shiftedValues(:, 30) * 0.9;  % Shifting here will usually just result in a smaller value. Swapping 5 and 7 would probably have a similar effect.
end
