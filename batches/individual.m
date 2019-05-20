% List indices in order of lowest to highest BVI.
function individual()
	plotAll = false;
	if nargin < 1
		plotAll = true;
		figToPlot = '';
	end

	iters = 30;
	sampleFraction = 0.8;

	% Load the data
	filepath = "bin/batch-normative.mat";
	load(filepath);
	clear nanMethod;

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	ba = BatchAnalyzer("Normative Data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	calculateBatch(ba);
	bas = [ba];

	for i=1:length(measures)
		ba = BACopyWithValues(ba, measures(i), values(:,i));
		calculateBatch(ba);
		bas = [bas ba];
	end

	% Sort with increasing homogeneity
	[~, ind] = sort([bas.Homogeneity_mean]);
	bas = bas(ind);

	plotBas(bas, 'individuals', 'Effects in Individual Measures');
end