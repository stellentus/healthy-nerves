%% getkSeekerBatches returns a list of BatchAnalyzer that investigate different cluster sizes.
function [bas] = getkSeekerBatches(iters, sampleFraction, filepath)
	load(filepath);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

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

	ba = BatchAnalyzer("3 Normative data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	bas = [
		%%%%%%%%%%% Different-sized Splits of Normative Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%

		BatchAnalyzer("2 SplitCAOnly", 2, [can1; can2], [ones(can1Num, 1); repmat(2, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 SplitJPOnly", 2, [jap1; jap2], [ones(jap1Num, 1); repmat(2, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 SplitPOOnly", 2, [por1; por2], [repmat(1, por1Num, 1); repmat(2, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		% Remove each type to see how things change
		BatchAnalyzer("2 No CA", 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 No JP", 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("2 No PO", 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);

		% Test the normative data
		ba;

		BatchAnalyzer("3 SplitCA,SubPO", 3, [can1; japValues; can2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("3 SplitJP,SubCA", 3, [jap1; porValues; jap2], [ones(jap1Num, 1); repmat(2, porNum, 1); repmat(3, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("3 SplitPO,SubJP", 3, [canValues; por1; por2], [ones(canNum, 1); repmat(2, por1Num, 1); repmat(3, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("4 Split CA", 4, [can1; japValues; porValues; can2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("4 Split JP", 4, [canValues; jap1; porValues; jap2], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("4 Split PO", 4, [canValues; japValues; por1; por2], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("5 Split CA,JP", 5, [can1; jap1; porValues; can2; jap2], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("5 Split JP,PO", 5, [canValues; jap1; por1; jap2; por2], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, jap2Num, 1); repmat(5, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("5 Split PO,CA", 5, [can1; japValues; por1; can2; por2], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("6 Split All", 6, [can1; jap1; por1; can2; jap2; por2], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1); repmat(6, por2Num, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		%%%%%%%%%%% Include Legs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% Show larger batches with CP instead of median
		BatchAnalyzer("3 Swap arm/legs", 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		% Show larger batches with CP instead of median
		BatchAnalyzer("4 Add legs", 4, [canValues; japValues; porValues; legValues], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1); repmat(4, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("5 Leg+Split CA", 5, [can1; japValues; porValues; can2; legValues], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1); repmat(5, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("5 Leg+Split JP", 5, [canValues; jap1; porValues; jap2; legValues], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, jap2Num, 1); repmat(5, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("5 Leg+Split PO", 5, [canValues; japValues; por1; por2; legValues], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, por2Num, 1); repmat(5, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("6 Leg+Split CA,JP", 6, [can1; jap1; porValues; can2; jap2; legValues], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, porNum, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1); repmat(6, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("6 Leg+Split JP,PO", 6, [canValues; jap1; por1; jap2; por2; legValues], [ones(canNum, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, jap2Num, 1); repmat(5, por2Num, 1); repmat(6, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("6 Leg+Split PO,CA", 6, [can1; japValues; por1; can2; por2; legValues], [ones(can1Num, 1); ones(japNum, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, por2Num, 1); repmat(6, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);

		BatchAnalyzer("7 Leg+Split All", 7, [can1; jap1; por1; can2; jap2; por2; legValues], [ones(can1Num, 1); ones(jap1Num, 1) * 2; repmat(3, por1Num, 1); repmat(4, can2Num, 1); repmat(5, jap2Num, 1); repmat(6, por2Num, 1); repmat(7, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
	];
end
