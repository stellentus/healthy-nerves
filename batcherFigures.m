% batcherFigures plots figures for the preliminary batch effect analysis.
function batcherFigures()
	iters = 30;
	sampleFraction = 0.8;

	load("bin/batch-normative.mat");

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	addpath batches;

	%%%%%%%%% FIGURE 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	ba = BatchAnalyzer("Normative data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	bas = [
		ba;
		BatchAnalyzer("Random labels", 3, values, 'iters', iters, 'sampleFraction', sampleFraction);
	];
	calcAndPlot(bas, 'batch-f1', 'Figure 1: Normative Data vs Random Data');

	%%%%%%%%% FIGURE 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	canIdx = randperm(canNum);
	can1 = canValues(canIdx(1:floor(length(canValues)/2)), :);
	can1Num = size(can1, 1);
	can2 = canValues(canIdx((floor(length(canValues)/2)+1):end), :);
	can2Num = size(can2, 1);

	japIdx = randperm(japNum);
	jap1 = japValues(japIdx(1:floor(length(japValues)/2)), :);
	jap1Num = size(jap1, 1);
	jap2 = japValues(japIdx((floor(length(japValues)/2)+1):end), :);
	jap2Num = size(jap2, 1);

	porIdx = randperm(porNum);
	por1 = porValues(porIdx(1:floor(length(porValues)/2)), :);
	por1Num = size(por1, 1);
	por2 = porValues(porIdx((floor(length(porValues)/2)+1):end), :);
	por2Num = size(por2, 1);

	bas = [
		%%%%%%%%%%% Random Data (should be 0) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		BatchAnalyzer("2 Random", 2, [japValues; porValues], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("3 Random", 3, values, 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("4 Random", 4, [values; legValues], 'iters', iters, 'sampleFraction', sampleFraction);

		%%%%%%%%%%% Different-sized Splits of Normative Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%

		BatchAnalyzer("2 SplitC (no J+P)", 2, [can1; can2], [ones(can1Num, 1); repmat(2, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 SplitJ (no J+P)", 2, [jap1; jap2], [ones(jap1Num, 1); repmat(2, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 SplitP (no J+P)", 2, [por1; por2], [repmat(1, por1Num, 1); repmat(2, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		% Remove each type to see how things change
		BatchAnalyzer("2 J+P", 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 C+P", 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 C+J", 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);

		% Test the normative data
		BatchAnalyzer("3 Normative (C+J+P)", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction)

		BatchAnalyzer("3 SplitC+J", 3, [can1; japValues; can2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("3 SplitJ+P", 3, [jap1; porValues; jap2], [ones(jap1Num, 1); repmat(2, porNum, 1); repmat(3, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("3 SplitP+C", 3, [canValues; por1; por2], [ones(canNum, 1); repmat(2, por1Num, 1); repmat(3, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("4 SplitC+J+P", 4, [can1; japValues; porValues; can2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("4 SplitJ+C+P", 4, [canValues; jap1; porValues; jap2], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("4 SplitP+C+J", 4, [canValues; japValues; por1; por2], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("5 SplitC+SplitJ+P", 5, [can1; jap1; porValues; can2; jap2], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("5 SplitJ+SplitP+C", 5, [canValues; jap1; por1; jap2; por2], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, jap2Num, 1); repmat(5, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("5 SplitP+SplitC+J", 5, [can1; japValues; por1; can2; por2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("6 Split All", 6, [can1; jap1; por1; can2; jap2; por2], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1); repmat(6, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
	];
	calcAndPlot(bas, 'batch-f2', 'Figure 2: Impact of Changing the Number of Groups');

	rmpath batches;
end

function calcAndPlot(bas, name, figtitle)
	% Calculate BE and print
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end

	plotBas(bas, name, figtitle);
end
