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

	iters = 30;

	addpath batches;

	ba = BatchAnalyzer("Normative data", iters, 3, values, labels);
	bas = [
		% Test the normative data
		ba;

		% Remove each type to see how things change
		% Conclusion with normalization: There isn't a batch between J and P, there might be one between C and P, and there's definitely one between C and J. But in all cases it's small.
		BatchAnalyzer("No Can", iters, 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2]);
		BatchAnalyzer("No Jap", iters, 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2]);
		BatchAnalyzer("No Por", iters, 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2]);

		% Confirm that random and perfectly batched data work as expected
		BatchAnalyzer("Random labels", iters, 3, values);
		% BatchAnalyzer("Batched data", iters, 3, length(labels)); % Instead of passing any data at all, request both arrays to be identical random indices;

		% Show larger batches with CP instead of median
		BatchAnalyzer("Canadian legs", iters, 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)]);

		% Look at batches when RC is shifted logarithmically in time.
		% Conclusion without normalization: Shifting everything right causes an increase in both measures, while shifting left causes a decrease. This may be due to the increase in magnitudes. (Perhaps this means RC is actually different between groups, but it only becomes dominant as RC values get larger relative to others. If so, I should scale all measures to have unit variance.) However, even though shifting everything causes an unexpected change, it's not significant, while the increase when only shifting Can is significant.
		% Conclusion with normalization: shifting to the right causes an increase, but not to the left. The change only appears in the Can shift, as expected.
		% BACopyWithValues(ba, "All shifted right RC", shiftRightRC(values));
		BACopyWithValues(ba, "Can shifted right RC", [shiftRightRC(canValues); japValues; porValues]);
		BACopyWithValues(ba, "Jap shifted right RC", [canValues; shiftRightRC(japValues); porValues]);
		BACopyWithValues(ba, "Por shifted right RC", [canValues; japValues; shiftRightRC(porValues)]);
		% BACopyWithValues(ba, "All shifted left RC", shiftLeftRC(values));
		BACopyWithValues(ba, "Can shifted left RC", [shiftLeftRC(canValues); japValues; porValues]);
		BACopyWithValues(ba, "Jap shifted left RC", [canValues; shiftLeftRC(japValues); porValues]);
		BACopyWithValues(ba, "Por shifted left RC", [canValues; japValues; shiftLeftRC(porValues)]);

		% Conclusion: All shrunk has no impact because it's all changed to unit variance, but shrinking just Can has a HUGE impact on clustering the Canadian data.
		% BatchAnalyzer("All shrunk RC", iters, 3, shrinkRC(values), labels);
		BACopyWithValues(ba, "Can shrunk RC", [shrinkRC(canValues); japValues; porValues]);
		BACopyWithValues(ba, "Jap shrunk RC", [canValues; shrinkRC(japValues); porValues]);
		BACopyWithValues(ba, "Por shrunk RC", [canValues; japValues; shrinkRC(porValues)]);

		% Conclusion: All reduced/increased has no impact because it's all changed to unit variance, but shrinking just Can decreases the ARI/NMI (while increasing increases), suggesting the Canadian data has more variance than the others.
		% BACopyWithValues(ba, "All increased variance", scaleVariance(values, 2.0));
		BACopyWithValues(ba, "Can increased variance", [scaleVariance(canValues, 2.0); japValues; porValues]);
		BACopyWithValues(ba, "Jap increased variance", [canValues; scaleVariance(japValues, 2.0); porValues]);
		BACopyWithValues(ba, "Por increased variance", [canValues; japValues; scaleVariance(porValues, 2.0)]);
		% BACopyWithValues(ba, "All decreased variance", scaleVariance(values, 0.5));
		BACopyWithValues(ba, "Can decreased variance", [scaleVariance(canValues, 0.5); japValues; porValues]);
		BACopyWithValues(ba, "Jap decreased variance", [canValues; scaleVariance(japValues, 0.5); porValues]);
		BACopyWithValues(ba, "Por decreased variance", [canValues; japValues; scaleVariance(porValues, 0.5)]);
		% BatchAnalyzer("All decreased variance", iters, 3, scaleVariance(values, .5), labels);
	];

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

	printBatchResults(str, cri_mean, cri_std, nmi_mean, nmi_std);
end

function printBatchResults(str, cri_mean, cri_std, nmi_mean, nmi_std)
	strs = pad(str);
	fprintf('%s |  CRI (std)     |  NMI (std)     \n', pad("Name", strlength(strs(1))));
	fprintf('%s | -------------- | -------------- \n', strrep(pad(" ", strlength(strs(1))), " ", "-"));
	for i=1:length(strs)
		fprintf('%s | % .3f (%.3f) | % .3f (%.3f) \n', strs(i), cri_mean(i), cri_std(i), nmi_mean(i), nmi_std(i));
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
	shiftedValues(:, 9) = shiftedValues(:, 9) * .5;
	shiftedValues(:, 26) = shiftedValues(:, 26) * .5;
	shiftedValues(:, 29) = shiftedValues(:, 29) * .5;
	shiftedValues(:, 30) = shiftedValues(:, 30) * .5;
	shiftedValues(:, 31) = shiftedValues(:, 31) * .5;
end

function [vals] = scaleVariance(vals, stdScale)
	colInd = [1:31];
	mns = mean(vals(:,colInd));
	vals(:,colInd) = bsxfun(@times, vals(:,colInd) - mns, stdScale) + mns;
end
