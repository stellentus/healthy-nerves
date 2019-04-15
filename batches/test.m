function test(dsNum, plGrp, shouldPlot)
	rng('default')  % For reproducibility

	[data1, data2] = getDataset(dsNum);

	figure(); % The box plots are shown regardless.
	bas = plotGroup(plGrp, data1, data2, shouldPlot);
	if shouldPlot
		subplot(2, 2, 4);
	end
	plottingBass(bas);
end

function [data1, data2] = getDataset(dsNum)
	% The default data doesn't overlap at all, and one cluster has a much different variance than the other.
	mu1 = [2 3];
	sigma1 = [1 1.5; 1.5 4];

	mu2 = 2*[-5 13];
	sigma2 = 5*[4 3; 3 3.5];

	switch dsNum
	case 1
		% Use the defaults.
	case 2
		% Dataset 2 has almost identical means, but different standard deviations. Even strongly batched data barely shows a difference.
		mu2 = [3 4];
	case 3
		% Dataset 3 has a moderate overlap between clusters.
		mu2 = [-2 5];
	case 4
		% Dataset 4 has NO clusters.
		mu2 = mu1;
		sigma2 = sigma1;
	otherwise
		warning("Dataset was not selected");
	end

	data1 = mvnrnd(mu1, sigma1, 5000);
	data2 = mvnrnd(mu2, sigma2, 5000);
end

function [bas] = plotGroup(plGrp, data1, data2, shouldPlot)
	switch plGrp
		% Test cases 1–4 show that regardless of whether I move some data points to a different cluster (maintaining the class ratio) or chagne the label of some classes (maintaining the cluster ratio), the batch measure changes by the same amount.
		% This also shows that changing a small percentage of points results in a BIG shift in the batch percentage.
	case 0
		% This only works if plotting is disabled.
		shouldPlot = false;
		bas = [
			plotBalancedGroups(data1, data2, 0.0, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.01, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.02, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.05, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.1, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.2, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.3, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.5, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.8, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 0.9, 500, shouldPlot);
			plotBalancedGroups(data1, data2, 1, 500, shouldPlot);
		];
	case 1
		% Test some groups that have complete batch effects.
		bas = [
			plotWithRange(data1, data2, 100, 0, 0, 100, 1, shouldPlot);
			plotWithRange(data1, data2, 500, 0, 0, 500, 2, shouldPlot);
			plotWithRange(data1, data2, 5000, 0, 0, 5000, 3, shouldPlot);
		];
	case 2
		% Test some groups that have very strong batch effects.
		% Even though just 2% of points from one cluster (and none from the other) are not batched, it's enough to drop the batch measure to 93%.
		bas = plotBalancedGroups(data1, data2, 0.02, 500, shouldPlot);
	case 3
		% Test some groups that have fairly strong batch effects.
		% Increasing the single-cluster un-batched data rate to 20% (of one half) drops the batch measure to 62%.
		bas = plotBalancedGroups(data1, data2, 0.2, 500, shouldPlot);
	case 4
		% Test some groups that have fairly strong batch effects, with either one cluster or one dataset fully homogeneous.
		% This increases the un-batched data rate to 50% (of one half), which drops the batch measure to 35%.
		bas = plotBalancedGroups(data1, data2, 0.5, 500, shouldPlot);
	case 5
		% Conclusion: If there are a lot of outliers (plot 3) or if there just isn't much data for one group (plot 2), the measure of batch effects will be low (8%, but it looks significant).
		bas = plotBalancedGroups(data1, data2, 0.9, 500, shouldPlot);
	case 6
		% Conclusion: Obviously in this case there are no batches, either because there's only one group (plot 2) or there's only one cluster (plot 3).
		bas = plotBalancedGroups(data1, data2, 1, 500, shouldPlot);
	case 10
		bas = [
			plotWithRange(data1, data2, 50, 50, 50, 50, 1, shouldPlot);
			plotWithRange(data1, data2, 50, 50, 450, 450, 2, shouldPlot);
			plotWithRange(data1, data2, 50, 450, 50, 450, 3, shouldPlot);
		];
	case 20
		bas = [
			plotWithRange(data1, data2, 80, 20, 20, 80, 1, shouldPlot);
			plotWithRange(data1, data2, 100, 80, 100, 120, 2, shouldPlot);
			plotWithRange(data1, data2, 100, 80, 40, 140, 3, shouldPlot);
		];
	case 100
		shouldPlot = true; % This must be plotted
		ba = [plotWithRange(data1, data2, 500, 0, 0, 500, 1, shouldPlot)];
		calculateBatch(ba);

		subplot(2, 2, 2);
		addpath ./lib/CategoricalScatterplot
		CategoricalScatterplot(ba.AllBaselineScores', string(ba.Score), 'MarkerSize', 50, 'BoxAlpha', .29);
		title('Baseline Distributions');
		xtickangle(45)
		plot([1:length(ba.Score)], ba.Score, 'x');

		subplot(2, 2, 3);
		CategoricalScatterplot([ba.Score; ba.BaselineScore; ba.ScoreDiff]', ["Scores"; "Diff"; "Baseline"], 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true);
		title('Diff of Scores');
		xtickangle(45)
		rmpath ./lib/CategoricalScatterplot

		bas = [ba];
	case 4000
		% Test The same as 4, but with 1/4 the data points.
		bas = plotBalancedGroups(data1, data2, 0.5, 125, shouldPlot);
	case 4001
		% Test The same as 4, but with the same data points and 300 resamples.
		bas = plotBalancedGroups(data1, data2, 0.5, 500, shouldPlot, 300);
	otherwise
		error("Dataset was not selected");
	end
end

% The following function finds the following batch percentages with total=500 and dataset 1.
% I'd call it "sagging linear". :)
% ratio=[0 0.01 0.02 0.05 0.1 0.2 0.3 0.5 0.8 0.9 1];
% batchPercent1=[100 96 93 86 76 62 51 35 15 8 0]; % Dataset 1 is clearly clustered
% batchPercent2=[11 10.5 10 9 9.5 6.5 4.5 2 0 0 0]; % Dataset 2 is mostly overlapping, so it's tough to separate even when the groups use separate clusters.
% batchPercent3=[25 23.5 22.5 22 23 17.5 17 14 3.5 1.5 0]; % Dataset 3 is somewhat clustered, so the mostly linear relationship continues as expected.
% Dataset 4 is not at all clustered, so obviously all values are 0.
% Conclusion: This is a pretty good measure of datapoints shifting toward batches, but it's not sensitive to small changes or overlapping clusters.
function [bas] = plotBalancedGroups(data1, data2, ratio, total, shouldPlot, iters)
	if nargin < 6
		iters = 30;
	end
	keep = round(ratio*total);
	remain = total-keep;

	bas = [
		plotWithRange(data1, data2, total, 0, 0, total, 1, shouldPlot, iters);
		plotWithRange(data1, data2, remain, 0, keep, total, 2, shouldPlot, iters);
		plotWithRange(data1, data2, remain, keep, 0, total, 3, shouldPlot, iters);
	];
end

function plottingBass(bas)
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end
	plotBas(bas, 'batch-norm-rand', 'Normative Data vs Random Data', struct('LadderLines', true));
end

function [ba] = plotData(d1, d2, name, subIdx, shouldPlot, iters)
	siz1 = size(d1, 1);
	siz2 = size(d2, 1);
	if shouldPlot
		subplot(2, 2, subIdx);
		hold on;
		plot(d1(:,1), d1(:,2), '+');
		plot(d2(:,1), d2(:,2), 'x');
		title(name);
		xlabel(sprintf("%d:%d", siz1, siz2));
	end

	labels = [ones(siz1, 1); ones(siz2, 1) * 2];
	ba = BatchAnalyzer(name, 2, [d1; d2], labels, 'iters', iters);
end

function [ba] = plotWithRange(data1, data2, n1a, n2a, n1b, n2b, plotIdx, shouldPlot, iters)
	if nargin < 9
		iters = 30;
	end
	range1a = 1:n1a;
	range2a = 1:n2a;
	range1b = (n1a+1):(n1b+n1a);
	range2b = (n2a+1):(n2b+n2a);

	% Calculate how much classes A and B are spread between the two clusters.
	ratioA = n1a/n2a;
	ratioB = n2b/n1b;
	percA = 100*(1-2/(ratioA+1));
	percB = 100*(1-2/(ratioB+1));

	classRatio = (n1a+n2a)/(n1b+n2b);
	nClassEqual = abs(classRatio-1.0) < 1e4*eps(min(classRatio, 1.0));
	clustRatio = (n1a+n1b)/(n2a+n2b);
	nClustEqual = abs(clustRatio-1.0) < 1e4*eps(min(clustRatio, 1.0));

	if nClassEqual && nClustEqual
		str = sprintf("Equals");
	elseif nClassEqual
		str = sprintf("Even Class (%.2f clust)", clustRatio);
	elseif nClustEqual
		str = sprintf("Even Clust (%.2f class)", classRatio);
	else
		str = sprintf("%.2f class; %.2f clust", classRatio, clustRatio);
	end

	namestring = sprintf("%.0f%% Batched (%.0f&%.0f); %s", (percA+percB)/2, percA, percB, str);
	ba = plotData([data2(range1a,:); data1(range2a,:)], [data2(range1b,:); data1(range2b,:)], namestring, plotIdx, shouldPlot, iters);
end
