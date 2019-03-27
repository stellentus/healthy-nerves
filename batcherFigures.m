% batcherFigures plots figures for the preliminary batch effect analysis.
function batcherFigures(figToPlot)
	plotAll = false;
	if nargin < 1
		plotAll = true;
	end

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

	% Calculate for the normative data, since this is used repeatedly for comparison.
	baNorm = BatchAnalyzer("Normative Data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	calculateBatch(baNorm);

	% Calculate for random labels with the same group sizes as the normative data.
	baRand = BatchAnalyzer("Random Labels", 3, size(values, 1), labels, 'iters', iters, 'sampleFraction', sampleFraction);
	calculateBatch(baRand);

	if plotAll || strcmp(figToPlot, 'norm-rand')
		fprintf('\n\nNormative Data vs Random Data\n\n');

		bas = [
			baNorm;
			baRand;
		];
		plotBas(bas, 'batch-norm-rand', 'Normative Data vs Random Data');
	end

	if strcmp(figToPlot, 'group-size-order')
		fprintf('\n\nImpact of Changing the Order of Groups\n\n');
		% This plot shows that the order of the random labels doesn't change the result as iters->inf.
		% I did this because smaller numbers of iterations appears to care about order.

		bas = [
			%%%%%%%%%%% Random Data (should be 0) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			BatchAnalyzer("2 Random c-j", [canNum, japNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("2 Random j-c", [japNum, canNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("2 Random c-p", [canNum, porNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("2 Random p-c", [porNum, canNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("2 Random j-p", [japNum, porNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("2 Random p-j", [porNum, japNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("3 Random c-j-p", [canNum, japNum, porNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("3 Random c-p-j", [canNum, porNum, japNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("3 Random j-p-c", [japNum, porNum, canNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("3 Random p-c-j", [porNum, canNum, japNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("4 Random c-j-p-l", [canNum, japNum, porNum, legNum], 'iters', 1000, 'sampleFraction', sampleFraction);
			BatchAnalyzer("4 Random p-l-j-c", [porNum, legNum, japNum, canNum], 'iters', 1000, 'sampleFraction', sampleFraction);
		];
		for i = 1:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-group-size-order', 'Impact of Changing the Order of Groups');
	end

	if plotAll || strcmp(figToPlot, 'group-size')
		fprintf('\n\nImpact of Changing the Number of Groups (60 samples within each)\n\n');

		bas = [
			%%%%%%%%%%% Random Data (should be 0) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			BatchAnalyzer("1 Random", 1, 60, repmat(1, 60, 1), 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("2 Random", repmat(60, 2, 1), 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("3 Random", repmat(60, 3, 1), 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("4 Random", repmat(60, 4, 1), 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("5 Random", repmat(60, 5, 1), 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("6 Random", repmat(60, 6, 1), 'iters', iters, 'sampleFraction', sampleFraction);
		];
		for i = 1:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-group-size', 'Impact of Changing the Number of Groups (60 samples within each)');
	end

	if plotAll || strcmp(figToPlot, 'vs-countries')
		fprintf('\n\nOne Country vs Two\n\n');

		bas = [
			baRand;
			baNorm;
			BatchAnalyzer("Normative vs Canada", 2, [canValues; japValues; porValues], [ones(canNum, 1); repmat(2, japNum+porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Normative vs Japan", 2, [japValues; canValues; porValues], [ones(japNum, 1); repmat(2, canNum+porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Normative vs Portugal", 2, [porValues; canValues; japValues], [ones(porNum, 1); repmat(2, japNum+canNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		];
		for i = 3:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-vs-countries', 'Comparisons with Leg Data');
	end

	if plotAll || strcmp(figToPlot, 'vs-legs')
		fprintf('\n\nComparisons with Leg Data\n\n');

		bas = [
			baRand;
			baNorm;
			BatchAnalyzer("Can Arms->Legs", 3, [legValues; japValues; porValues], [ones(legNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Add Legs", 4, [values; legValues], [labels; repmat(4, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Normative vs Legs", 2, [values; legValues], [repmat(1, length(labels), 1); repmat(2, legNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		];
		for i = 3:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-vs-legs', 'Comparisons with Leg Data');
	end

	if plotAll || strcmp(figToPlot, 'vs-sci')
		fprintf('\n\nComparisons with SCI Data\n\n');

		bas = [
			baRand;
			baNorm;
			BatchAnalyzer("Can->SCI", 3, [sciValues; japValues; porValues], [ones(sciNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Por->SCI", 3, [canValues; japValues; sciValues], [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, sciNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Add SCI", 4, [values; sciValues], [labels; repmat(4, sciNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Normative vs SCI", 2, [values; sciValues], [repmat(1, length(labels), 1); repmat(2, sciNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		];
		for i = 3:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-vs-sci', 'Comparisons with SCI Data');
	end

	if plotAll || strcmp(figToPlot, 'within-rats')
		fprintf('\n\nComparisons Within a Rat Dataset\n\n');

		bas = [
			baRand;
			baNorm;
			BatchAnalyzer("Rat KX vs SP", 2, [ratKXValues; ratSPValues], [ones(ratKXNum, 1); ones(ratSPNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Rat TA vs SOL", 2, [ratTAValues; ratSLValues], [ones(ratTANum, 1); ones(ratSLNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("4 Rat Types", 4, [ratTASPValues; ratTAKXValues; ratSLSPValues; ratSLKXValues], [repmat(1, ratTASPNum, 1); repmat(2, ratTAKXNum, 1); repmat(3, ratSLSPNum, 1); repmat(4, ratSLKXNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		];
		for i = 3:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-within-rats', 'Comparisons with Non-Normative Data');
	end

	if plotAll || strcmp(figToPlot, 'vs-rats')
		fprintf('\n\nComparisons with Rat Data\n\n');

		bas = [
			baRand;
			baNorm;
			BatchAnalyzer("Can->Rat", 3, [ratValues; japValues; porValues], [ones(ratNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Jap->Rat", 3, [canValues; ratValues; porValues], [ones(canNum, 1); ones(ratNum, 1) * 2; repmat(3, porNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Add Rats", 4, [values; ratValues], [labels; repmat(4, ratNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
			BatchAnalyzer("Human vs Rats", 2, [values; ratValues], [repmat(1, length(labels), 1); repmat(2, ratNum, 1)], 'iters', iters, 'sampleFraction', sampleFraction);
		];
		for i = 3:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-vs-rats', 'Comparisons with Rat Data');
	end

	if plotAll || strcmp(figToPlot, 'rc')
		fprintf('\n\nAdjusting Recovery Cycle (RC)\n\n');

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
		plotBas(bas, 'batch-rc', 'Adjusting Recovery Cycle (RC)');
	end

	if plotAll || strcmp(figToPlot, 'variance')
		fprintf('\n\nAdjusting Variance\n\n');

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
		plotBas(bas, 'batch-variance', 'Adjusting Variance');
	end

	if plotAll || strcmp(figToPlot, 'delete-features')
		fprintf('\n\nImpact of Deleting Each Feature\n\n');

		bas = [
			baRand;
			getDeletedFeatureBatches(iters, sampleFraction, filepath, false, struct('toDelete', 1));
		];
		for i = 2:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(sortByMean(bas), 'batch-delete-features', 'Impact of Deleting Each Feature');
	end

	if plotAll || strcmp(figToPlot, 'triple-deletion')
		fprintf('\n\nMost and Least Impactful Triple-Deletions\n\n');

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
		plotBas(bas, 'batch-triple-deletion', 'Most and Least Impactful Triple-Deletions');
	end

	if plotAll || strcmp(figToPlot, 'quintuple-deletion')
		fprintf('\n\nAssorted Quintuple-Deletions\n\n');

		bas = [
			baRand;
			baNorm;
			BACopyWithValues(baNorm, 'Remove Best 5', values(:, setdiff(1:length(measures), [2, 25, 11, 18, 14])));
			getDeletedFeatureBatches(iters, sampleFraction, filepath, false, struct('toDelete', 5, 'maxNum', 10));  % Choose 10 combinations of 5 indices at random
		];
		for i = 3:length(bas)
			calculateBatch(bas(i));
		end
		plotBas(bas, 'batch-quintuple-deletion', 'Assorted Quintuple-Deletions');
	end

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
