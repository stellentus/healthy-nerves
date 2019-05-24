% batchMultiDimDemos creates some demo plots for batch effect VI homogeneity in many dimensions.
function batchMultiDimDemos()
	[~,~] = mkdir('img/batch'); % Read and ignore returns to suppress warning if dir exists.

	addpath batches;

	padLen = 4;
	BatchAnalyzer.printHeader(padLen);

	makePlot1();

	BatchAnalyzer.printDivider(padLen);
	makePlot2(2);
	BatchAnalyzer.printDivider(padLen);
	makePlot2(35);

	BatchAnalyzer.printDivider(padLen);
	makePlot3();

	BatchAnalyzer.printDivider(padLen);
	makePlot4(1000, 30);
	BatchAnalyzer.printDivider(padLen);
	makePlot4(100, 30);
	BatchAnalyzer.printDivider(padLen);
	makePlot4(100, 300);

	BatchAnalyzer.printDivider(padLen);
	makePlot5();

	BatchAnalyzer.printDivider(padLen);
	makePlot6(100);
	BatchAnalyzer.printDivider(padLen);
	makePlot6(1000);

	rmpath batches;
end

% This is the original for reference.
function makePlot1()
	mu1 = [2 3];
	sigma1 = [1 1.5; 1.5 4];

	mu2 = 2*[-5 13];
	sigma2 = 5*[4 3; 3 3.5];

	data1 = mvnrnd(mu1, sigma1, 5000);
	data2 = mvnrnd(mu2, sigma2, 5000);

	makeThePlots("dims-two-different", data1, data2);
end

% For non-overlapping distributions (where the means are separated by multiple standard
% deviations), the results are always the same at any number of dimensions: 0%, 38%, 92%,
% 100%. (I only tested at 2 and 35 dimensions.) Consider that to be the "true" homogeneity.
% Once they start overlapping, the two-dimensional version quickly approaches 100% for all
% four tests, since it can't distinguish between the minor differences in the mean and sd.
% (It obviously has even more trouble distinguishing at lower numbers of samples.) At
% higher dimensions, I think it has an easier time figuring out that the data is separate.
% Since each dimension is independent with the same mean and sd, I'm essentially giving it
% 35 data points per sample instead of just 2.
function makePlot2(dims) % Try this with 2 and 35.
	distBetween = 1.5;
	[data1, data2] = getStandardData(dims, distBetween);
	makeThePlots("dims-uniform", data1, data2);
end

% This raises the question: what if 33 dimensions are from identical distributions, but the
% other two are from different distributions. Clustering will preferentially uses the
% different distributions, giving good results. However, the noise from the 33 identical
% distributions does make the results slightly worse: 1%, 39%, 92%, 100%. But "worse" here
% means observation of *increased* homogeneity, and only when the true data is
% heterogeneous. So for data that's mostly homogeneous, it looks like batching in just two
% dimensions is easily detectable.
function makePlot3()
	dims = 32;
	distBetween = 1.5;
	[data1, data2] = getStandardData(dims, distBetween);

	% Now prepend the two columns from different distributions
	% The results are exactly the same with appending. It's just a matter of which columns are plotted.
	[other1, other2] = getOtherData();
	data1 = [other1 data1];
	data2 = [other2 data2];

	makeThePlots("dims-two-different", data1, data2);
end

% So far this has all been independent data (except the two columns from the original
% tests). Let's generate data from the Canadian median NET data. This is a fascinating
% result: since the distance between is 0, the only difference between the two
% distributions is the covariance matrix, which is scaled by a factor of 3 for the second
% distribution. So we get homogeneity scores of 100%, but small p-values. Usually
% p-values are large when homogeneity approaches 100%. This is especially strange given
% that the last plot is actually from the same distribution. Stranger still, if the
% number of samples is reduced to 100, the first 3 plots give large p-values (indicating
% they're indistinguishable from being the same distribution), while the last plot has a
% small p-value. This is strange because the last plot is the only one that actually is
% from the same distribution.
% Increasing to 300 iterations fixes this problem, giving a larger p-value for the last
% plot.
function makePlot4(numSamples, iters)
	distBetween = 0;
	covMat = getPSDcov();
	[data1, data2] = getStandardData(covMat, distBetween);
	makeThePlots("dims-dependent", data1, data2, numSamples, iters);
end

% The last test ended up also showing that if the means are identical, it's very
% difficult to detect heterogeneity. This test furthers that by making a miniscule change
% to the distance between and showing much larger heterogeneity. (Though this 'miniscule'
% change is actually about a standard deviation, I think.)
function makePlot5()
	distBetween = 0.01;
	covMat = getPSDcov();
	[data1, data2] = getStandardData(covMat, distBetween);
	makeThePlots("dims-dependent-shift", data1, data2, 100, 300);
end

% Now try generating data from the exact same distribution, but add two features which are
% extremely different. This is like makePlot3, but the 31 same-distribution features are
% dependent.
% These results are...problematic. With 100 samples, it's not possible to tell some data
% comes from different distributions, so we get 99–100% with tiny p-values.
% This shows that the clustering algorithm can get confused by a lot of features. As a
% result, we think data is homogeneous when two of the 33 features are not.
% It's a bit better with 1000 samples. Even though the homogeneity ratio increases, the
% p-values drop, indicating increased confidence that the distributions are actually
% different. (But maybe that's just because of the extra samples, and the clustering
% still fails to use the two important dimensions.)
function makePlot6(numSamples)
	distBetween = 0; % Same mean for both
	covrScale = 1; % Same covr for both
	covMat = getPSDcov();
	[data1, data2] = getStandardData(covMat, distBetween, covrScale);

	% Now prepend the two columns from different distributions
	% The results are exactly the same with appending. It's just a matter of which columns are plotted.
	[other1, other2] = getOtherData();
	data1 = [data1 other1 ];
	data2 = [data2 other2 ];

	makeThePlots("dims-outlier-dimensions", data1, data2, numSamples);
end

% CONCLUSION: This measure won't necessarily notice small changes in a single feature.
% I'm still not sure how to reproduce the 95% homogeneity we're seeing in the normative
% data.

function makeThePlots(name, data1, data2, numSamples, iters)
	if nargin < 4
		numSamples = 100;
	end
	if nargin < 5
		iters = 30;
	end

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 480 600]);

	plotWithRange(1, data1, data2, 1, 0, 0, 1, iters, numSamples, "0%");
	plotWithRange(2, data1, data2, .8, 0, .2, 1, iters, numSamples, "38%");
	plotWithRange(3, data1, data2, .1, .9, 0, 1, iters, numSamples, "92%");
	plotWithRange(4, data1, data2, 0, 1, 0, 1, iters, numSamples, "100%");

	saveFigureToBatchDir(name, fig);
end

function [data1, data2] = getStandardData(covMat, distBetween, covrScale)
	if nargin < 3
		covrScale = 3;
	end

	dims = length(covMat);
	if dims == 1
		dims = covMat;
		covMat = eye(dims)*2;
	end

	rng('default');  % For reproducibility
	data1 = mvnrnd(zeros(1, dims), covMat, 100000);
	data2 = mvnrnd(distBetween*ones(1, dims), covMat*covrScale, 100000);
end

function [data1, data2] = getOtherData()
	mu1 = [2 3];
	sigma1 = [1 1.5; 1.5 4];

	mu2 = 2*[-5 13];
	sigma2 = 5*[4 3; 3 3.5];

	data1 = mvnrnd(mu1, sigma1, 100000);
	data2 = mvnrnd(mu2, sigma2, 100000);
end

function saveFigureToBatchDir(name, fig)
	pathstr = sprintf('img/batch/%s-%02d-%02d-%02d-%02d-%02d-%02.0f', name, clock);
	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/batch/', name, '.png')); % Also save without timestamp
end

function plotWithRange(plotId, data1, data2, n1a, n2a, n1b, n2b, iters, numSamples, letterLabel)
	% Scale fractions by number of samples
	n1a = n1a*numSamples;
	n1b = n1b*numSamples;
	n2a = n2a*numSamples;
	n2b = n2b*numSamples;

	d1 = [data2(1:n1a,:); data1(1:n2a,:)];
	d2 = [data2((n1a+1):(n1b+n1a),:); data1((n2a+1):(n2b+n2a),:)];

	siz1 = size(d1, 1);
	siz2 = size(d2, 1);

	labels = [ones(siz1, 1); ones(siz2, 1) * 2];
	ba = BatchAnalyzer(letterLabel, 2, [d1; d2], labels, 'iters', iters);
	calculateBatch(ba);

	padLen = 4;
	disp(BAString(ba, padLen));

	par = [
		.01 .60;
		.49 .60;
		.01 .31;
		.49 .31;
		.01 .02;
		.49 .02;
	];

	if plotId ~= 0
		pos = [par(plotId, 1) par(plotId, 2) .31 .27];
		sb = subplot('Position', pos, 'Units', 'normalized');
		set(sb, 'YTick', [], 'XTick', []);
		hold on;
		plot(d1(:,1), d1(:,2), 'o', 'color', [0,73,137]/255);
		plot(d2(:,1), d2(:,2), 'x', 'color', [43,111,0]/255);
		  text(0.05, 0.95, letterLabel, 'fontweight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'cap', 'Units', 'normalized');
		pos(1) = pos(1) + 0.315;
		pos(3) = 0.12;
		subplot('Position', pos, 'Units', 'normalized');
		plotBA(ba);
		if mod(plotId, 2) == 0
			ylabel('Homogeneity (%)');
		end
	end
end

% plotBA is used to print a table and one BatchAnalyzer
function plotBA(ba)
	scores = [ba.Score'/ba.BaselineScore_mean ba.BaselineScore'/ba.BaselineScore_mean];
	plotBoxes(scores, ["Homog.", "|Max|"]);
	ylim([0 1.15])

		  textLabel = sprintf("%2.0f%%\nHomog.\n\np=%s", ba.Homogeneity_mean*100, PString(ba));
	x = 1.5;
	y = 0.6;
	if ba.Homogeneity_mean < 0.50 && ba.Homogeneity_mean > .1
		y = 0.9;
	end
		  text(x, y, textLabel, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap');
end

function plotBoxes(scores, testNames)
	addpath lib/CategoricalScatterplot

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true);
	set(gca, 'YAxisLocation', 'right');
	set(gca,'FontSize', 8)

	rmpath lib/CategoricalScatterplot
end

function [Ahat] = getPSDcov()
	% 'A' comes from my actual data, but rounding errors mean it's no longer positive semidefinite.
	A = [0.0034 0 0.0022 0.0001 0.0006 0 0 0.0001 0 0.0059 0.0006 0.0014 0.0008 0.0015 0.0003 0.0002 0.0001 0.0002 0.0008 0.0001 0.0006 0.0004 0.0006 0.0005 0 0 0.0016 0.0001 0.0018 0.0014 0.0018; 0 0 0 0 0 0 0 0 0 0.0002 0.0001 0.0001 0.0001 0.0004 0 0 0 0 0.0002 0.0001 0.0001 0.0001 0.0001 0.0002 0 0.0001 0.0002 0 0.0002 0.0001 0.0001; 0.0022 0 0.0015 0.0001 0.0004 0 0 0 0 0.0037 0.0003 0.0008 0.0007 0.0005 0.0002 0.0002 0.0001 0.0002 0.0002 0.0001 0.0002 0.0002 0.0004 0.0001 0 0.0001 0.0007 0 0.0017 0.0007 0.0010; 0.0001 0 0.0001 0.0018 0.0005 0 0 0.0001 0 0.0012 0.0001 0.0006 0.0008 0.0022 0.0001 0.0001 0.0008 0.0003 0.0015 0.0008 0.0004 0.0003 0.0005 0.0013 0 0.0006 0.0019 0.0001 0 0.0009 0.0004; 0.0006 0 0.0004 0.0005 0.0123 0 0 0.0001 0.0002 0.0035 0.0007 0.0001 0.0017 0.0053 0.0003 0.0001 0.0003 0.0004 0.0005 0.0004 0 0 0.0004 0.0024 0 0.0103 0.0003 0.0001 0.0166 0.0003 0.0008; 0 0 0 0 0 0 0 0 0 0.0013 0.0003 0.0002 0.0001 0.0001 0 0 0.0002 0.0003 0.0003 0.0001 0.0002 0.0003 0.0001 0.0001 0 0.0009 0.0005 0 0.0013 0.0002 0.0002; 0 0 0 0 0 0 0 0 0 0.0005 0 0.0001 0 0.0002 0 0 0.0001 0 0 0 0 0.0001 0 0 0 0 0.0001 0 0.0001 0.0001 0.0001; 0.0001 0 0 0.0001 0.0001 0 0 0.0004 0 0.0002 0.0003 0.0004 0.0006 0.0012 0 0.0001 0 0.0001 0.0001 0.0006 0.0008 0.0003 0.0004 0.0001 0 0.0032 0.0001 0 0.0061 0.0007 0.0003; 0 0 0 0 0.0002 0 0 0 0.0002 0.0032 0.0006 0.0011 0.0001 0.0005 0 0.0001 0.0001 0.0007 0.0010 0.0003 0.0007 0.0004 0.0002 0.0009 0 0.0070 0.0015 0 0.0108 0.0005 0.0014; 0.0059 0.0002 0.0037 0.0012 0.0035 0.0013 0.0005 0.0002 0.0032 0.3074 0.0535 0.0503 0.0053 0.0287 0.0009 0.0004 0.0348 0.0453 0.0704 0.0039 0.0154 0.0521 0.0068 0.0188 0.0001 0.1450 0.1237 0.0043 0.2018 0.0419 0.0525; 0.0006 0.0001 0.0003 0.0001 0.0007 0.0003 0 0.0003 0.0006 0.0535 0.0209 0.0128 0.0053 0.0038 0.0002 0 0.0092 0.0118 0.0194 0.0051 0.0039 0.0192 0.0075 0.0078 0.0001 0.0292 0.0301 0.0010 0.0348 0.0108 0.0136; 0.0014 0.0001 0.0008 0.0006 0.0001 0.0002 0.0001 0.0004 0.0011 0.0503 0.0128 0.0370 0.0021 0.0254 0.0007 0 0.0153 0.0111 0.0101 0.0041 0.0003 0.0161 0.0050 0.0053 0 0.0318 0.0186 0.0006 0.0253 0.0376 0.0369; 0.0008 0.0001 0.0007 0.0008 0.0017 0.0001 0 0.0006 0.0001 0.0053 0.0053 0.0021 0.0281 0.0239 0.0002 0.0003 0.0106 0.0049 0.0067 0.0119 0.0140 0.0029 0.0078 0.0102 0 0.0092 0.0087 0.0004 0.0237 0.0045 0.0002; 0.0015 0.0004 0.0005 0.0022 0.0053 0.0001 0.0002 0.0012 0.0005 0.0287 0.0038 0.0254 0.0239 0.1958 0.0003 0.0021 0.0176 0.0054 0.0142 0.0158 0.0191 0.0032 0.0022 0.0191 0.0003 0.0129 0.0104 0.0006 0.0136 0.0291 0.0242; 0.0003 0 0.0002 0.0001 0.0003 0 0 0 0 0.0009 0.0002 0.0007 0.0002 0.0003 0.0003 0.0001 0.0001 0.0002 0.0001 0.0001 0.0001 0.0002 0 0.0002 0 0.0006 0.0001 0 0.0005 0.0006 0.0008; 0.0002 0 0.0002 0.0001 0.0001 0 0 0.0001 0.0001 0.0004 0 0 0.0003 0.0021 0.0001 0.0005 0.0003 0.0003 0.0001 0.0004 0.0005 0.0001 0.0004 0.0008 0 0.0029 0.0001 0 0.0052 0.0004 0.0003; 0.0001 0 0.0001 0.0008 0.0003 0.0002 0.0001 0 0.0001 0.0348 0.0092 0.0153 0.0106 0.0176 0.0001 0.0003 0.0217 0.0139 0.0033 0.0044 0.0065 0.0129 0.0011 0.0119 0 0.0037 0.0079 0.0001 0.0005 0.0179 0.0125; 0.0002 0 0.0002 0.0003 0.0004 0.0003 0 0.0001 0.0007 0.0453 0.0118 0.0111 0.0049 0.0054 0.0002 0.0003 0.0139 0.0181 0.0124 0.0058 0.0075 0.0120 0.0062 0.0034 0 0.0333 0.0202 0.0005 0.0493 0.0088 0.0105; 0.0008 0.0002 0.0002 0.0015 0.0005 0.0003 0 0.0001 0.0010 0.0704 0.0194 0.0101 0.0067 0.0142 0.0001 0.0001 0.0033 0.0124 0.0312 0.0052 0.0030 0.0158 0.0034 0.0162 0.0001 0.0509 0.0444 0.0015 0.0709 0.0050 0.0121; 0.0001 0.0001 0.0001 0.0008 0.0004 0.0001 0 0.0006 0.0003 0.0039 0.0051 0.0041 0.0119 0.0158 0.0001 0.0004 0.0044 0.0058 0.0052 0.0157 0.0145 0.0052 0.0110 0.0017 0 0.0274 0.0079 0.0004 0.0554 0.0055 0.0041; 0.0006 0.0001 0.0002 0.0004 0 0.0002 0 0.0008 0.0007 0.0154 0.0039 0.0003 0.0140 0.0191 0.0001 0.0005 0.0065 0.0075 0.0030 0.0145 0.0224 0.0034 0.0108 0.0025 0 0.0447 0.0024 0.0004 0.0781 0.0022 0.0009; 0.0004 0.0001 0.0002 0.0003 0 0.0003 0.0001 0.0003 0.0004 0.0521 0.0192 0.0161 0.0029 0.0032 0.0002 0.0001 0.0129 0.0120 0.0158 0.0052 0.0034 0.0197 0.0077 0.0021 0.0001 0.0166 0.0254 0.0008 0.0122 0.0158 0.0158; 0.0006 0.0001 0.0004 0.0005 0.0004 0.0001 0 0.0004 0.0002 0.0068 0.0075 0.0050 0.0078 0.0022 0 0.0004 0.0011 0.0062 0.0034 0.0110 0.0108 0.0077 0.0138 0.0013 0 0.0167 0.0052 0.0003 0.0371 0.0070 0.0053; 0.0005 0.0002 0.0001 0.0013 0.0024 0.0001 0 0.0001 0.0009 0.0188 0.0078 0.0053 0.0102 0.0191 0.0002 0.0008 0.0119 0.0034 0.0162 0.0017 0.0025 0.0021 0.0013 0.0248 0 0.0448 0.0219 0.0008 0.0725 0.0123 0.0013; 0 0 0 0 0 0 0 0 0 0.0001 0.0001 0 0 0.0003 0 0 0 0 0.0001 0 0 0.0001 0 0 0 0.0004 0.0001 0 0.0006 0 0 ; 0 0.0001 0.0001 0.0006 0.0103 0.0009 0 0.0032 0.0070 0.1450 0.0292 0.0318 0.0092 0.0129 0.0006 0.0029 0.0037 0.0333 0.0509 0.0274 0.0447 0.0166 0.0167 0.0448 0.0004 0.3933 0.0716 0.0019 0.6310 0.0046 0.0486; 0.0016 0.0002 0.0007 0.0019 0.0003 0.0005 0.0001 0.0001 0.0015 0.1237 0.0301 0.0186 0.0087 0.0104 0.0001 0.0001 0.0079 0.0202 0.0444 0.0079 0.0024 0.0254 0.0052 0.0219 0.0001 0.0716 0.0724 0.0025 0.0964 0.0111 0.0208; 0.0001 0 0 0.0001 0.0001 0 0 0 0 0.0043 0.0010 0.0006 0.0004 0.0006 0 0 0.0001 0.0005 0.0015 0.0004 0.0004 0.0008 0.0003 0.0008 0 0.0019 0.0025 0.0001 0.0026 0.0003 0.0006; 0.0018 0.0002 0.0017 0 0.0166 0.0013 0.0001 0.0061 0.0108 0.2018 0.0348 0.0253 0.0237 0.0136 0.0005 0.0052 0.0005 0.0493 0.0709 0.0554 0.0781 0.0122 0.0371 0.0725 0.0006 0.6310 0.0964 0.0026 1.0708 0.0189 0.0527; 0.0014 0.0001 0.0007 0.0009 0.0003 0.0002 0.0001 0.0007 0.0005 0.0419 0.0108 0.0376 0.0045 0.0291 0.0006 0.0004 0.0179 0.0088 0.0050 0.0055 0.0022 0.0158 0.0070 0.0123 0 0.0046 0.0111 0.0003 0.0189 0.0421 0.0362; 0.0018 0.0001 0.0010 0.0004 0.0008 0.0002 0.0001 0.0003 0.0014 0.0525 0.0136 0.0369 0.0002 0.0242 0.0008 0.0003 0.0125 0.0105 0.0121 0.0041 0.0009 0.0158 0.0053 0.0013 0 0.0486 0.0208 0.0006 0.0527 0.0362 0.0393];

	% The following portion of this function is Copyright (c) 2013, John D'Errico
	% It was downloaded from https://www.mathworks.com/matlabcentral/fileexchange/42885-nearestspd
	% All rights reserved.

	% Redistribution and use in source and binary forms, with or without
	% modification, are permitted provided that the following conditions are met:

	% * Redistributions of source code must retain the above copyright notice, this
	%   list of conditions and the following disclaimer.

	% * Redistributions in binary form must reproduce the above copyright notice,
	%   this list of conditions and the following disclaimer in the documentation
	%   and/or other materials provided with the distribution
	% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
	% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

	% From Higham: "The nearest symmetric positive semidefinite matrix in the
	% Frobenius norm to an arbitrary real matrix A is shown to be (B + H)/2,
	% where H is the symmetric polar factor of B=(A + A')/2."
	%
	% http://www.sciencedirect.com/science/article/pii/0024379588902236

	% symmetrize A into B
	B = (A + A')/2;
	% Compute the symmetric polar factor of B. Call it H.
	% Clearly H is itself SPD.
	[U,Sigma,V] = svd(B);
	H = V*Sigma*V';
	% get Ahat in the above formula
	Ahat = (B+H)/2;
	% ensure symmetry
	Ahat = (Ahat + Ahat')/2;
	% test that Ahat is in fact PD. if it is not so, then tweak it just a bit.
	p = 1;
	k = 0;
	while p ~= 0
		[R,p] = chol(Ahat);
		k = k + 1;
		if p ~= 0
			% Ahat failed the chol test. It must have been just a hair off,
			% due to floating point trash, so it is simplest now just to
			% tweak by adding a tiny multiple of an identity matrix.
			mineig = min(eig(Ahat));
			Ahat = Ahat + (-mineig*k.^2 + eps(mineig))*eye(size(A));
		end
	end
end

