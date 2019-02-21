%% getDeletedFeatureBatches returns a list of BatchAnalyzer that delete each feature.
function [bas] = getDeletedFeatureBatches(iters)
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];
	values = [canValues; japValues; porValues];
	numFeat = length(measures);

	ba = BatchAnalyzer("Normative", 3, [canValues; japValues; porValues], labels, 'iters', iters);
	bas = [ba];
	for i = [1:numFeat]
		bas = [bas BACopyWithValues(ba, sprintf('Remove %s', measures(i)), values(:,setdiff(1:numFeat,[i])))];
		% bas = [bas BACopyWithValues(ba, sprintf('Only %s', measures(i)), values(:,setdiff(1:numFeat,[i])))];
	end
end
