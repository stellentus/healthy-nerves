%% getDeletedFeatureBatches returns a list of BatchAnalyzer that delete each feature.
% These results somewhat point to SDTC, Hyperpol I/V slope, TEd(10-20ms), TEd(90-100ms), and Age [2, 25, 11, 18, 14], but it's not really significant.
%% arg.toDelete is the number of indices to delete (default 1).
function [bas] = getDeletedFeatureBatches(iters, sampleFraction, filepath, arg)
	load(filepath);

	if nargin < 4
		arg = struct();
	end
	if ~isfield(arg, 'toDelete')
		arg.toDelete = 1;
	end
	if ~isfield(arg, 'maxNum')
		arg.maxNum = 0;
	end

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];
	values = [canValues; japValues; porValues];
	numFeat = length(measures);

	ba = BatchAnalyzer("Normative Data", 3, [canValues; japValues; porValues], labels, 'iters', iters, 'sampleFraction', sampleFraction);
	bas = [];

	% Try all permutations of removals of the desired number of indices
	combos = nchoosek(1:31, arg.toDelete);

	% If the number is limited, shorten 'combos'; else add normative data
	if arg.maxNum ~= 0 && arg.maxNum <= size(combos, 1)
		randomIndices = randperm(size(combos, 1));
		combos = combos(randomIndices(1:arg.maxNum), :);
	else
		bas = [ba];
	end

	for i = 1:size(combos, 1)
		bas = [bas; BACopyWithValues(ba, printVector('Remove', combos(i, :)), values(:,setdiff(1:numFeat,combos(i, :))))];
	end
end

function str = printVector(str, vec)
	str = sprintf("%s [", str);

	fmtStr = "%s%d"; % This variable makes sure a space is only added after the first
	for i=1:length(vec)
		str = sprintf(fmtStr, str, vec(i));
		fmtStr = "%s %d";
	end

	str = sprintf("%s]", str);
end
