%% getDeletedFeatureBatches returns a list of BatchAnalyzer that delete each feature.
% These results somewhat point to SDTC, Hyperpol I/V slope, TEd(10-20ms), TEd(90-100ms), and Age, but it's not really significant.
function [bas] = getDeletedFeatureBatches(iters)
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];
	values = [canValues; japValues; porValues];
	numFeat = length(measures);

	ba = BatchAnalyzer("Normative", 3, [canValues; japValues; porValues], labels, 'iters', iters);
	bas = [ba];
	for i = 1:numFeat
		% bas = [bas BACopyWithValues(ba, sprintf('Remove %s (%d)', measures(i), i), values(:,setdiff(1:numFeat,[i])))];
	end

	% Try all two-index removals
	combos = nchoosek(1:31,2);
	for i = 1:size(combos, 1)
		bas = [bas BACopyWithValues(ba, printVector('Remove', combos(i, :)), values(:,setdiff(1:numFeat,combos(i, :))))];
	end

	% Try combinations of the special list
	special = [2 11 14 18 25];
	for i=2:length(special)
		combos = nchoosek(special, i);
		for i = 1:size(combos, 1)
			bas = [bas BACopyWithValues(ba, printVector('Remove', combos(i, :)), values(:,setdiff(1:numFeat,combos(i, :))))];
		end
	end
end

function str = printVector(str, vec)
	str = sprintf("%s [", str);
	for i=1:length(vec)
		str = sprintf("%s%d ", str, vec(i));
	end
	str = sprintf("%s]", str);
end
