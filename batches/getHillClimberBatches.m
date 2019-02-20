%% getHillClimberBatches returns a list of BatchAnalyzer that try to seek out a transformation that minimizes the batch effects.
function getHillClimberBatches(iters, useNMI)
	if nargin < 2
		useNMI = false;
	end

	load('bin/batch-normative.mat');
	vals.can = canValues;
	vals.jap = japValues;
	vals.por = porValues;
	clear canValues japValues porValues;

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(vals.can, 1), 1); ones(size(vals.jap, 1), 1) * 2; repmat(3, size(vals.por, 1), 1)];
	numMeas = length(measures);

	weight.Jap.Std = zeros(1, numMeas);
	weight.Jap.Mn = zeros(1, numMeas);
	weight.Por.Std = zeros(1, numMeas);
	weight.Por.Mn = zeros(1, numMeas);
	printWeights(weight);

	lastBestBatch = 1;
	threshold = 1e-7;
	mag = 0;
	ba = BatchAnalyzer('Normative', 3, [vals.can; vals.jap; vals.por], labels, 'iters', iters);
	thisBatch = batchVal(ba, useNMI);
	fprintf("Batch effect is %.4f\n", thisBatch);
	while abs(thisBatch - lastBestBatch) > threshold && mag < 20
		lastBestBatch = thisBatch;
		for i=1:numMeas
			[weight.Jap.Std(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Jap.Std(i), weight, thisBatch, i, mag, @scaledBAJapStd, 'JapSt');
			[weight.Jap.Mn(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Jap.Mn(i), weight, thisBatch, i, mag, @scaledBAJapMn, 'JapMn');
			[weight.Por.Std(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Por.Std(i), weight, thisBatch, i, mag, @scaledBAPorStd, 'PorSt');
			[weight.Por.Mn(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Por.Mn(i), weight, thisBatch, i, mag, @scaledBAPorMn, 'PorMn');
		end
		printWeights(weight);
		fprintf("Batch effect is %.4f\n", thisBatch);
		mag = mag + 1;
	end
	disp("Done");
end

function [vals] = scaleValues(vals, stdScale, mnBias)
	mns = mean(vals);
	vals = bsxfun(@times, vals - mns, 1+stdScale) + mns + mnBias;
end

function thisBatch = batchVal(ba, useNMI)
	calculateBatch(ba);
	if useNMI
		thisBatch = abs(mean(ba.NMI));
	else
		thisBatch = abs(mean(ba.CRI));
	end
end

function ba = scaledBAJapStd(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt.Jap.Std+modwgt, wgt.Jap.Mn); scaleValues(vals.por, wgt.Por.Std, wgt.Por.Mn)]);
end

function ba = scaledBAJapMn(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt.Jap.Std, wgt.Jap.Mn+modwgt); scaleValues(vals.por, wgt.Por.Std, wgt.Por.Mn)]);
end

function ba = scaledBAPorStd(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt.Jap.Std, wgt.Jap.Mn); scaleValues(vals.por, wgt.Por.Std+modwgt, wgt.Por.Mn)]);
end

function ba = scaledBAPorMn(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt.Jap.Std, wgt.Jap.Mn); scaleValues(vals.por, wgt.Por.Std, wgt.Por.Mn+modwgt)]);
end

function [wt, thisBatch] = optimize(ba, vals, useNMI, numMeas, curr, weight, origBatch, i, mag, scaledBAFunc, str)
	modWeight = zeros(1, numMeas);
	adj = .1/(2^mag);
	count = 0;
	thisBatch = origBatch;
	lastBatch = 0;
	epsilon = 1e-5;

	while abs(thisBatch-lastBatch) > epsilon && count < mag + 2
		lastBatch = thisBatch;
		origWeight = modWeight(i);
		modWeight(i) = modWeight(i) + adj;
		ba = scaledBAFunc(ba, vals, weight, modWeight);
		thisBatch = batchVal(ba, useNMI);

		% Now predict the adjustment to give zero BE if it were linear.
		adj = lastBatch*adj/(lastBatch-thisBatch) + origWeight;

		% Prevent values from straying too far.
		if curr + modWeight(i) + adj < -1
			% fprintf("\t\tAttempt to move to % .4f\n", curr + modWeight(i) + adj);
			adj = -1-curr-modWeight(i);
		elseif curr + modWeight(i) + adj > 1
			% fprintf("\t\tAttempt to move to % .4f\n", curr + modWeight(i) + adj);
			adj = 1-curr-modWeight(i);
		end

		% Only go partway, since we don't want to overshoot
		count = count + 1;
		adj = adj/count/numMeas;
	end

	if origBatch < thisBatch
		wt = 0;
		thisBatch = origBatch;
		fprintf('\t-Update %s weight at %2d (BE %.4f; %2d iters) keep % .3f\n', str, i, lastBatch, count, curr);
	else
		wt = curr + modWeight(i);
		fprintf('\tUpdated %s weight at %2d (BE %.4f; %2d iters) from % .3f to % .3f\n', str, i, thisBatch, count, curr, wt);
	end
end

function printWeights(weight)
	printWeight("JAP ST", weight.Jap.Std);
	printWeight("JAP MN", weight.Jap.Mn);
	printWeight("POR ST", weight.Por.Std);
	printWeight("POR MN", weight.Por.Mn);
end

function printWeight(str, wt)
	num = length(wt);
	fprintf("%s: ", str)
	for i=1:num
		fprintf("%.3f ", wt(i));
	end
	fprintf("\n")
end
