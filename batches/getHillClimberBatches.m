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

	randLimit = 0.2;
	weight.Jap.Std = -randLimit + (randLimit+randLimit)*rand(1, numMeas);
	weight.Jap.Mn = -randLimit + (randLimit+randLimit)*rand(1, numMeas);
	weight.Por.Std = -randLimit + (randLimit+randLimit)*rand(1, numMeas);
	weight.Por.Mn = -randLimit + (randLimit+randLimit)*rand(1, numMeas);
	printWeights(weight);

	lastBestBatch = 1;
	threshold = 1e-7;
	mag = 0;

	ba = BatchAnalyzer('Normative', 3, [vals.can; vals.jap; vals.por], labels, 'iters', iters);
	thisBatch = batchVal(ba, useNMI);
	fprintf("Original batch effect is %.4f\n", thisBatch);
	thisBatch = batchVal(BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, weight.Jap.Std, weight.Jap.Mn); scaleValues(vals.por, weight.Por.Std, weight.Por.Mn)]), useNMI);
	fprintf("Scaled batch effect is %.4f\n", thisBatch);

	while abs(thisBatch - lastBestBatch) > threshold && mag < 20
		lastBestBatch = thisBatch;
		for i=randperm(numMeas)
			[weight.Jap.Std(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Jap.Std(i), weight, thisBatch, i, mag, @scaledBAJapStd, 'JapSt');
			[weight.Jap.Mn(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Jap.Mn(i), weight, thisBatch, i, mag, @scaledBAJapMn, 'JapMn');
			[weight.Por.Std(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Por.Std(i), weight, thisBatch, i, mag, @scaledBAPorStd, 'PorSt');
			[weight.Por.Mn(i), thisBatch] = optimize(ba, vals, useNMI, numMeas, weight.Por.Mn(i), weight, thisBatch, i, mag, @scaledBAPorMn, 'PorMn');
		end
		printWeights(weight);
		fprintf("Batch effect decreased from %.4f %.4f\n", lastBestBatch, thisBatch);
		mag = mag + 1;
	end
	disp("Done");
end

function [vals] = scaleValues(vals, stdScale, mnBias)
	mns = mean(vals);
	vals = bsxfun(@times, vals - mns, exp(stdScale)) + mns + mnBias;
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
	adj = .3/(2^mag);
	thisBatch = origBatch;
	lastBatch = 0;
	epsilon = 1e-5;
	minDelta = 0.003/(2^mag);
	wt = curr;

	modWeight(i) = modWeight(i) + adj;
	incBatch = batchVal(scaledBAFunc(ba, vals, weight, modWeight), useNMI);
	modWeight(i) = modWeight(i) - 2*adj;
	decBatch = batchVal(scaledBAFunc(ba, vals, weight, modWeight), useNMI);

	if decBatch < incBatch
		% It's better to decrease
		adj = -adj;
		% fprintf('\t |----- %s weight at %2d (BE %.4f; -1 iters) adju % .3f\n', str, i, thisBatch, adj);
	elseif incBatch < origBatch - minDelta
		% Increasing is an adequate improvement to keep going
		modWeight(i) = modWeight(i) + 2*adj; % Set modWeight back to what worked
		% fprintf('\t |----- %s weight at %2d (BE %.4f; -1 iters) adju % .3f\n', str, i, thisBatch, adj);
	else
		return
	end

	count = 0;
	while abs(thisBatch-lastBatch) > epsilon && count < mag + 10
		lastBatch = thisBatch;
		modWeight(i) = modWeight(i) + adj;
		thisBatch = batchVal(scaledBAFunc(ba, vals, weight, modWeight), useNMI);
		% fprintf('\t |----- %s weight at %2d (BE %.4f; %2d iters) adju % .3f\n', str, i, thisBatch, count, adj);

		if thisBatch > lastBatch
			% We've gone to far, so go back and quit
			modWeight(i) = modWeight(i) - adj;
			thisBatch = lastBatch;
			break;
		end
		count = count + 1;
	end

	if origBatch < thisBatch
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
		fprintf("% .3f ", wt(i));
	end
	fprintf("\n")
end
