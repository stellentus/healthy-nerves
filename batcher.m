%% batcher detects batch effects.
function [brs] = batcher()
	load('bin/batch-normative.mat');

	% Get and print count of each group and age range
	canNum = printStats(canValues, 'Canada');
	japNum = printStats(japValues, 'Japan');
	porNum = printStats(porValues, 'Portugal');
	legNum = printStats(legValues, 'Legs');
	disp(" "); % Newline

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	% Calculate and print measures of batching
	iters = 30;
	rng('shuffle');
	scurr = rng(); % Ensure all start with the same seed
	scurr.Seed = 7738;

	brs = struct('str', [], 'cri_mean', [], 'cri_std', [], 'nmi_mean', [], 'nmi_std', []);

	% Test the normative data
	brs = getBatchResults(brs, "Normative data", iters, scurr.Seed, @kmeans, 3, values, labels);

	% Remove each type to see how things change
	% Conclusion with normalization: There isn't a batch between J and P, there might be one between C and P, and there's definitely one between C and J. But in all cases it's small.
	brs = getBatchResults(brs, "No Canada", iters, scurr.Seed, @kmeans, 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2]);
	brs = getBatchResults(brs, "No Japan", iters, scurr.Seed, @kmeans, 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2]);
	brs = getBatchResults(brs, "No Portugal", iters, scurr.Seed, @kmeans, 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2]);

	% Confirm that random and perfectly batched data work as expected
	brs = getBatchResults(brs, "Random labels", iters, scurr.Seed, @kmeans, 3, values);
	% brs = getBatchResults(brs, "Batched data", iters, scurr.Seed, @kmeans, 3, length(labels)); % Instead of passing any data at all, request both arrays to be identical random indices.

	% Show larger batches with CP instead of median
	brs = getBatchResults(brs, "Canadian legs", iters, scurr.Seed, @kmeans, 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)]);

	% Look at batches when RC is shifted logarithmically in time.
	% Conclusion without normalization: Shifting everything right causes an increase in both measures, while shifting left causes a decrease. This may be due to the increase in magnitudes. (Perhaps this means RC is actually different between groups, but it only becomes dominant as RC values get larger relative to others. If so, I should scale all measures to have unit variance.) However, even though shifting everything causes an unexpected change, it's not significant, while the increase when only shifting Canada is significant.
	% Conclusion with normalization: shifting to the right causes an increase, but not to the left. The change only appears in the Canada shift, as expected.
	brs = getBatchResults(brs, "All shifted right RC", iters, scurr.Seed, @kmeans, 3, shiftRightRC(values), labels);
	brs = getBatchResults(brs, "Canada shifted right RC", iters, scurr.Seed, @kmeans, 3, [shiftRightRC(canValues); japValues; porValues], labels);
	brs = getBatchResults(brs, "All shifted left RC", iters, scurr.Seed, @kmeans, 3, shiftLeftRC(values), labels);
	brs = getBatchResults(brs, "Canada shifted left RC", iters, scurr.Seed, @kmeans, 3, [shiftLeftRC(canValues); japValues; porValues], labels);

	% Conclusion: All shrunk has no impact because it's all changed to unit variance, but shrinking just Canada has a HUGE impact on clustering the Canadian data.
	% brs = getBatchResults(brs, "All shrunk RC", iters, scurr.Seed, @kmeans, 3, shrinkRC(values), labels);
	brs = getBatchResults(brs, "Canada shrunk RC", iters, scurr.Seed, @kmeans, 3, [shrinkRC(canValues); japValues; porValues], labels);

	% Conclusion: All reduced/increased has no impact because it's all changed to unit variance, but shrinking just Canada decreases the ARI/NMI (while increasing increases), suggesting the Canadian data has more variance than the others.
	% brs = getBatchResults(brs, "All reduced variance", iters, scurr.Seed, @kmeans, 3, scaleVariance(values, 2.0), labels);
	brs = getBatchResults(brs, "Canada reduced variance", iters, scurr.Seed, @kmeans, 3, [scaleVariance(canValues, 2.0); japValues; porValues], labels);
	% brs = getBatchResults(brs, "All increased variance", iters, scurr.Seed, @kmeans, 3, scaleVariance(values, .5), labels);
	brs = getBatchResults(brs, "Canada increased variance", iters, scurr.Seed, @kmeans, 3, [scaleVariance(canValues, .5); japValues; porValues], labels);

	printBatchResults(brs);
end

function [val] = zeroMeanUnitVar(val, mns, stds)
	val = val - mns;
	val = bsxfun(@rdivide, val, stds);
end

% calculateBatchResults will repeatedly calculate batch results with
function [cri, norm_mutual] = calculateBatchResults(iters, seed, clusterFunc, numGroups, values, labels)
	cri = [];
	norm_mutual = [];
	rng(seed); % Ensure all start with the same seed

	% If there's only one value that means 'values' is instead an integer length of random indices.
	randomIndices = (numel(values) == 1);
	if ~randomIndices
		values = zeroMeanUnitVar(values, mean(values), std(values));
	end

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

function [brs] = getBatchResults(brs, str, varargin)
	[cri, normMutual] = calculateBatchResults(varargin{:});
	brs.str = [brs.str, str];
	brs.cri_mean = [brs.cri_mean, mean(cri)];
	brs.cri_std = [brs.cri_std, std(cri)];
	brs.nmi_mean = [brs.nmi_mean, mean(normMutual)];
	brs.nmi_std = [brs.nmi_std, std(normMutual)];
end

function printBatchResults(brs)
	strs = pad(brs.str);
	fprintf('%s |  CRI (std)     |  NMI (std)     \n', pad("Name", strlength(strs(1))));
	fprintf('%s | -------------- | -------------- \n', strrep(pad(" ", strlength(strs(1))), " ", "-"));
	for i=1:length(strs)
		fprintf('%s | % .3f (%.3f) | % .3f (%.3f) \n', strs(i), brs.cri_mean(i), brs.cri_std(i), brs.nmi_mean(i), brs.nmi_std(i));
	end
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

function [shiftedValues] = shiftRightRC(vals)
	shiftedValues = vals;
	shiftedValues(:, 9) = shiftedValues(:, 9) * 1.2;  % Shift RRP right by 20%
	shiftedValues(:, 26) = shiftedValues(:, 26) * 1.3;  % Shift Ref@2.5 right by increasing value by 30%.
	shiftedValues(shiftedValues(:, 26)<0, 26) = 0;  % However, this might be <0, so set those to 0.
	shiftedValues(:, 29) = shiftedValues(:, 29) * 1.4;  % Shift Ref@2.0 right by increasing value by 40%
	shiftedValues(:, 30) = shiftedValues(:, 31);  % Shift Super@7 to equal the Super@5 value
	shiftedValues(:, 30) = shiftedValues(:, 30) * 0.9;  % Shifting here will usually just result in a smaller value. Swapping 5 and 7 would probably have a similar effect.
end

function [shiftedValues] = shiftLeftRC(vals)
	shiftedValues = vals;
	shiftedValues(:, 9) = shiftedValues(:, 9) * .8;  % Shift RRP left by 20%
	shiftedValues(:, 26) = shiftedValues(:, 26) * .7;  % Shift Ref@2.5 left by decreasing value by 30%.
	shiftedValues(shiftedValues(:, 26)<0, 26) = 0;  % However, this might be <0, so set those to 0.
	shiftedValues(:, 29) = shiftedValues(:, 29) * .6;  % Shift Ref@2.0 left by decreasing value by 40%
	shiftedValues(:, 31) = shiftedValues(:, 30);  % Shift Super@5 to equal the Super@7 value
	shiftedValues(:, 31) = shiftedValues(:, 31) * 1.1;  % Shifting here will usually just result in a larger value. Swapping 5 and 7 would probably have a similar effect.
end

function [shiftedValues] = shrinkRC(vals)
	shiftedValues = vals;
	shiftedValues(:, 9) = shiftedValues(:, 9) * .1;
	shiftedValues(:, 26) = shiftedValues(:, 26) * .1;
	shiftedValues(:, 29) = shiftedValues(:, 29) * .1;
	shiftedValues(:, 30) = shiftedValues(:, 30) * .1;
	shiftedValues(:, 31) = shiftedValues(:, 31) * .1;
end

function [vals] = scaleVariance(vals, stdScale)
	mns = mean(vals);
	vals = bsxfun(@times, vals - mns, stdScale) + mns;
end
