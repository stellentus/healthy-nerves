%% getDeletedFeatureBatches returns a list of BatchAnalyzer that delete each feature.
% These results somewhat point to SDTC, Hyperpol I/V slope, TEd(10-20ms), TEd(90-100ms), and Age, but it's not really significant.
%% arg.toDelete is the number of indices to delete (default 1).
function [bas] = getDeletedFeatureBatches(iters, filepath, arg)
	load(filepath);

	if nargin < 2
		arg = struct();
	end
	if ~isfield(arg, 'toDelete')
		arg.toDelete = 1;
	end

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];
	values = [canValues; japValues; porValues];
	numFeat = length(measures);

	ba = BatchAnalyzer("Normative", 3, [canValues; japValues; porValues], labels, 'iters', iters);
	bas = [ba];

	% Try all permutations of removals of the desired number of indices
	combos = nchoosek(1:31, arg.toDelete);
	for i = 1:size(combos, 1)
		bas = [bas BACopyWithValues(ba, printVector('Remove', combos(i, :)), values(:,setdiff(1:numFeat,combos(i, :))))];
	end
end

function str = printVector(str, vec)
	str = sprintf("%s [", str);
	for i=1:length(vec)
		str = sprintf("%s%d ", str, vec(i));
	end
	str = sprintf("%s]", str);
end
