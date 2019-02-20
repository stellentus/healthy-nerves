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

	randLimit = 0.0005;
	weight = -randLimit + (randLimit+randLimit)*rand(4, numMeas);
	printWeights(weight);

	lastBestBatch = 1;
	threshold = 1e-10;
	mag = 0;

	ba = BatchAnalyzer('Normative', 3, [vals.can; vals.jap; vals.por], labels, 'iters', iters);
	origBatch = batchVal(ba, useNMI);
	thisBatch = batchVal(BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, weight(1,:), weight(2,:)); scaleValues(vals.por, weight(3,:), weight(4,:))]), useNMI);
	fprintf("Original batch effect is %.4f, scaled up to %.4f\n", origBatch, thisBatch);

	while abs(thisBatch - lastBestBatch) > threshold && mag < 100
		lastBestBatch = thisBatch;
		for i=randperm(numMeas)
			minDelta = 0.001/(2^mag);
			epsilon = 1e-7;
			adj = 1/(2^mag);

			[weight(1,i), thisBatch] = optimize(ba, vals, useNMI, numMeas, minDelta, epsilon, adj, weight(1,i), weight, thisBatch, i, mag, @scaledBAJapStd, 'JapSt');
			[weight(2,i), thisBatch] = optimize(ba, vals, useNMI, numMeas, minDelta, epsilon, adj, weight(2,i), weight, thisBatch, i, mag, @scaledBAJapMn, 'JapMn');
			[weight(3,i), thisBatch] = optimize(ba, vals, useNMI, numMeas, minDelta, epsilon, adj, weight(3,i), weight, thisBatch, i, mag, @scaledBAPorStd, 'PorSt');
			[weight(4,i), thisBatch] = optimize(ba, vals, useNMI, numMeas, minDelta, epsilon, adj, weight(4,i), weight, thisBatch, i, mag, @scaledBAPorMn, 'PorMn');
		end
		printWeights(weight);
		fprintf("Batch effect decreased from %.4f %.4f\n", lastBestBatch, thisBatch);
		mag = mag + 1;
	end
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
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt(1,:)+modwgt, wgt(2,:)); scaleValues(vals.por, wgt(3,:), wgt(4,:))]);
end

function ba = scaledBAJapMn(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt(1,:), wgt(2,:)+modwgt); scaleValues(vals.por, wgt(3,:), wgt(4,:))]);
end

function ba = scaledBAPorStd(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt(1,:), wgt(2,:)); scaleValues(vals.por, wgt(3,:)+modwgt, wgt(4,:))]);
end

function ba = scaledBAPorMn(ba, vals, wgt, modwgt)
	ba = BACopyWithValues(ba, 'scaled', [vals.can; scaleValues(vals.jap, wgt(1,:), wgt(2,:)); scaleValues(vals.por, wgt(3,:), wgt(4,:)+modwgt)]);
end

function [wt, thisBatch] = optimize(ba, vals, useNMI, numMeas, minDelta, epsilon, adj, curr, weight, origBatch, i, mag, scaledBAFunc, str)
	modWeight = zeros(1, numMeas);
	thisBatch = origBatch;
	lastBatch = 0;
	wt = curr;

	modWeight(i) = modWeight(i) + adj;
	incBatch = batchVal(scaledBAFunc(ba, vals, weight, modWeight), useNMI);
	modWeight(i) = modWeight(i) - 2*adj;
	decBatch = batchVal(scaledBAFunc(ba, vals, weight, modWeight), useNMI);

	if decBatch < incBatch && decBatch < origBatch - minDelta
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
	while count < mag + 3
		count = count + 1;
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
	end

	if thisBatch < origBatch - minDelta
		wt = curr + modWeight(i);
		fprintf('\tUpdated %s weight at %2d (BE %.4f; %2d iters) from % .3f to % .3f\n', str, i, thisBatch, count, curr, wt);
	else
		thisBatch = origBatch;
		fprintf('\t-Update %s weight at %2d (BE %.4f; %2d iters) keep % .3f\n', str, i, lastBatch, count, curr);
	end
end

function printWeights(weight)
	printWeight("JAP ST", weight(1,:));
	printWeight("JAP MN", weight(2,:));
	printWeight("POR ST", weight(3,:));
	printWeight("POR MN", weight(4,:));
end

function printWeight(str, wt)
	num = length(wt);
	fprintf("%s: ", str)
	for i=1:num
		fprintf("% .3f ", wt(i));
	end
	fprintf("\n")
end
