% testtic shows that tic/toc works within parfor. It would be nice to do this a bit better with t-tests.

% with threads=50 and actionsPerThread=50 , this took 2m35.323s to run remotely on my VM on Matthias's computer:
% 	Average error per test (para): 0.000239 (0.000755) with mean 0.060208 and fraction 0.3969% (1.2537).
% 	Average error per test (sing): 0.000215 (0.000041) with mean 0.060208 and fraction 0.3960% (0.0763).

% with threads=100 and actionsPerThread=200, this took 20m35.903s to run remotely on my VM on Matthias's computer:
% 	Average error per test (para): 0.000211 (0.000094) with mean 0.062459 and fraction 0.34% (0.15).
% 	Average error per test (sing): 0.000217 (0.000054) with mean 0.062459 and fraction 0.39% (0.10).
function testtic
	threads = 100;
	actionsPerThread = 200;

	paraRuntimeDiff = zeros(threads, actionsPerThread);
	paraRMean = zeros(threads, 1);
	parfor i = 1:threads
		[paraRuntimeDiff(i,:), paraRMean(i)] = loopThroughThreads(actionsPerThread);
	end
	paraRuntimeFraction = paraRuntimeDiff/mean(paraRMean)*100;
	fprintf("Average error per test (para): %f (%f) with mean %f and fraction %.2f%% (%.2f).\n", mean(paraRuntimeDiff(:)), std(paraRuntimeDiff(:)), mean(paraRMean), mean(paraRuntimeFraction(:)), std(paraRuntimeFraction(:)));

	singRuntimeDiff = zeros(threads, actionsPerThread);
	singRMean = zeros(threads, 1);
	for i = 1:threads
		[singRuntimeDiff(i,:), singRMean(i)] = loopThroughThreads(actionsPerThread);
	end
	singRuntimeFraction = singRuntimeDiff/mean(singRMean)*100;
	fprintf("Average error per test (sing): %f (%f) with mean %f and fraction %.2f%% (%.2f).\n", mean(singRuntimeDiff(:)), std(singRuntimeDiff(:)), mean(paraRMean), mean(singRuntimeFraction(:)), std(singRuntimeFraction(:)));
end

function [rDiff, rMean] = loopThroughThreads(actionsPerThread)
	rng(7738);
	rDiff = zeros(1, actionsPerThread);
	rMean = 0;
	for j = 1:actionsPerThread
		pauseTime = 0.01 + rand()/10;
		rMean = rMean + pauseTime;
		tic;
		pause(pauseTime);
		rDiff(1, j) = toc-pauseTime;
	end
	rMean = rMean / actionsPerThread;
end
