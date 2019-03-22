% batcherFigures plots figures for the preliminary batch effect analysis.
function batcherFigures()
	iters = 30;
	sampleFraction = 0.8;

	% Load the data
	filepath = "bin/batch-normative.mat";
	load(filepath);
	normMeas = measures;
	load("bin/non-normative.mat");
	assert(isequal(normMeas, measures), 'Measures for normative and non-normative are not the same');
	clear normMeas nanMethod;

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	addpath batches;

	baNorm = BatchAnalyzer("Normative Data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	calculateBatch(baNorm);
	baRand = BatchAnalyzer("Random Labels", 3, values, 'iters', iters, 'sampleFraction', sampleFraction);
	calculateBatch(baRand);

	%%%%%%%% FIGURE 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 1\n');

	bas = [
		baNorm;
		baRand;
	];
	plotBas(bas, 'batch-f1', 'Figure 1: Normative Data vs Random Data');

	%%%%%%%%% FIGURE 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 2\n');

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
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-f2', 'Figure 2: Impact of Changing the Number of Groups');

	%%%%%%%%% FIGURE 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 3\n');

	bas = [
		baRand;
		baNorm;
		BatchAnalyzer("Can Arms->Legs", 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Add Legs", 4, [values; legValues], [labels; repmat(4, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Can->SCI", 3, [sciValues; japValues; porValues], [ones(sciNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Por->SCI", 3, [canValues; japValues; sciValues], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, sciNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Jap->Rat", 3, [canValues; ratValues; porValues], [ones(canNum, 1); ones(ratNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Can->(Rat+SCI)", 3, [ratValues; sciValues; japValues; porValues], [ones(ratNum+sciNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Arms/SCI/Legs/Rats", 4, [values; sciValues; legValues; ratValues], [repmat(1, length(labels), 1); repmat(2, sciNum, 1); repmat(3, legNum, 1); repmat(4, ratNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Rat KX vs SP", 2, [ratKXValues; ratSPValues], [ones(ratKXNum, 1); ones(ratSPNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Rat TA vs SOL", 2, [ratTAValues; ratSLValues], [ones(ratTANum, 1); ones(ratSLNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("4 Rat Types", 4, [ratTASPValues; ratTAKXValues; ratSLSPValues; ratSLKXValues], [repmat(1, ratTASPNum, 1); repmat(2, ratTAKXNum, 1); repmat(3, ratSLSPNum, 1); repmat(4, ratSLKXNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Arms vs Legs", 2, [values; legValues], [repmat(1, length(labels), 1); repmat(2, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Humans vs Rats", 2, [values; sciValues; legValues; ratValues], [repmat(1, length(labels)+sciNum+legNum, 1); repmat(2, ratNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Human Arms vs Rats", 2, [values; ratValues], [repmat(1, length(labels), 1); repmat(2, ratNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		BatchAnalyzer("Human Not-Arms vs Rats", 2, [sciValues; legValues; ratValues], [repmat(1, sciNum+legNum, 1); repmat(2, ratNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
	];
	for i = 3:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-f3', 'Figure 3: Comparisons with Non-Normative Data');

	%%%%%%%%% FIGURE 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 4\n');

	bas = [
		baRand;
		baNorm;

		BACopyWithValues(baNorm, "Can shift right", [shiftRightRC(canValues); japValues; porValues]);
		BACopyWithValues(baNorm, "Jap shift right", [canValues; shiftRightRC(japValues); porValues]);
		BACopyWithValues(baNorm, "Por shift right", [canValues; japValues; shiftRightRC(porValues)]);

		BACopyWithValues(baNorm, "Can shift left", [shiftLeftRC(canValues); japValues; porValues]);
		BACopyWithValues(baNorm, "Jap shift left", [canValues; shiftLeftRC(japValues); porValues]);
		BACopyWithValues(baNorm, "Por shift left", [canValues; japValues; shiftLeftRC(porValues)]);

		BACopyWithValues(baNorm, "Can shrink", [shrinkRC(canValues); japValues; porValues]);
		BACopyWithValues(baNorm, "Jap shrink", [canValues; shrinkRC(japValues); porValues]);
		BACopyWithValues(baNorm, "Por shrink", [canValues; japValues; shrinkRC(porValues)]);
	];
	for i = 3:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-f4', 'Figure 4: Adjusting Recovery Cycle (RC)');

	%%%%%%%%% FIGURE 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 5\n');

	bas = [
		baRand;
		baNorm;

		BACopyWithValues(baNorm, "Can increased variance", [scaleVariance(canValues, 2.0); japValues; porValues]);
		BACopyWithValues(baNorm, "Jap increased variance", [canValues; scaleVariance(japValues, 2.0); porValues]);
		BACopyWithValues(baNorm, "Por increased variance", [canValues; japValues; scaleVariance(porValues, 2.0)]);

		BACopyWithValues(baNorm, "Can decreased variance", [scaleVariance(canValues, 0.5); japValues; porValues]);
		BACopyWithValues(baNorm, "Jap decreased variance", [canValues; scaleVariance(japValues, 0.5); porValues]);
		BACopyWithValues(baNorm, "Por decreased variance", [canValues; japValues; scaleVariance(porValues, 0.5)]);
	];
	for i = 3:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-f5', 'Figure 5: Adjusting variance');

	%%%%%%%% FIGURE 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 6\n');

	bas = [
		baRand;
		getDeletedFeatureBatches(iters, sampleFraction, filepath, false, struct('toDelete', 1));
	];
	for i = 2:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(sortByMean(bas), 'batch-f6', 'Figure 6: Impact of Deleting Each Feature');

	%%%%%%%% FIGURE 7 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 7\n');

	bas = getDeletedFeatureBatches(iters, sampleFraction, filepath, false, struct('toDelete', 3));
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end
	bas = sortByMean(bas);
	bas = [
		baRand;
		bas(1:10);
		baNorm;
		bas(end-9:end);
	];
	plotBas(bas, 'batch-f7', 'Figure 7: Most and Least Impactful Triple-Deletions');

	%%%%%%%% FIGURE 8 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fprintf('\n\nFigure 8\n');

	bas = [
		baRand;
		baNorm;
		BACopyWithValues(baNorm, 'Remove Best 5', values(:, setdiff(1:length(measures), [2, 25, 11, 18, 14])));
		getDeletedFeatureBatches(iters, sampleFraction, filepath, false, struct('toDelete', 5, 'maxNum', 10));  % Choose 10 combinations of 5 indices at random
	];
	for i = 3:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-f8', 'Figure 8: Assorted Quintuple-Deletions');

	rmpath batches;
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

function [bas] = sortByMean(bas)
	[~, ind] = sort([bas.NMI_mean]);
	bas = bas(ind);
end
