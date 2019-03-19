%% getkSeekerBatches returns a list of BatchAnalyzer that investigate different cluster sizes.
function [bas] = getkSeekerBatches(iters, sampleFraction, filepath, calcHell)
	load(filepath);

	canNum = size(canValues, 1);
	japNum = size(japValues, 1);
	porNum = size(porValues, 1);
	legNum = size(legValues, 1);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	can1 = canValues(1:floor(length(canValues)/2), :);
	can1Num = size(can1, 1);
	can2 = canValues((floor(length(canValues)/2)+1):end, :);
	can2Num = size(can2, 1);
	jap1 = japValues(1:floor(length(japValues)/2), :);
	jap1Num = size(jap1, 1);
	jap2 = japValues((floor(length(japValues)/2)+1):end, :);
	jap2Num = size(jap2, 1);
	por1 = porValues(1:floor(length(porValues)/2), :);
	por1Num = size(por1, 1);
	por2 = porValues((floor(length(porValues)/2)+1):end, :);
	por2Num = size(por2, 1);

	ba = BatchAnalyzer("Normative data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
	bas = [
		% Test the normative data
		ba;

		% Remove each type to see how things change
		BatchAnalyzer("No Can", 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("No Jap", 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("No Por", 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);

		% Confirm that random and perfectly batched data work as expected
		BatchAnalyzer("Random 3", 3, values, 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Random 2c", 2, [japValues; porValues], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Random 2j", 2, [canValues; porValues], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Random 2p", 2, [japValues; canValues], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);

		% Show larger batches with CP instead of median
		BatchAnalyzer("Swap arm/legs", 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);

		% Show larger batches with CP instead of median
		BatchAnalyzer("Add legs", 4, [canValues; japValues; porValues; legValues], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1); repmat(4, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);

		BatchAnalyzer("Split Can", 4, [can1; japValues; porValues; can2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Split Jap", 4, [canValues; jap1; porValues; jap2], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Split Por", 4, [canValues; japValues; por1; por2], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);

		BatchAnalyzer("Split CanJap", 5, [can1; jap1; porValues; can2; jap2], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Split JapPor", 5, [canValues; jap1; por1; jap2; por2], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, jap2Num, 1); repmat(5, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
		BatchAnalyzer("Split PorCan", 5, [can1; japValues; por1; can2; por2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);

		BatchAnalyzer("Split All", 6, [can1; jap1; por1; can2; jap2; por2], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1); repmat(6, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction, 'calcHell', calcHell);
	];
end


