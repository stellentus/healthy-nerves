% batcherFigures plots figures for the preliminary batch effect analysis.
function batcherFigures()
	iters = 30;
	sampleFraction = 0.8;

	load("bin/batch-normative.mat");

	canNum = size(canValues, 1);
	japNum = size(japValues, 1);
	porNum = size(porValues, 1);
	legNum = size(legValues, 1);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	addpath batches;

	ba = BatchAnalyzer("Normative data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	bas = [
		ba;
		BatchAnalyzer("Random labels", 3, values, 'iters', iters, 'sampleFraction', sampleFraction);
	];

	calcAndPlot(bas, 'batch-f1');

	rmpath batches;
end

function calcAndPlot(bas, name)
	% Calculate BE and print
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end

	plotBas(bas, name);
end
