%% batchVarSeeker tries to seek out the indices with the strongest variance-induced batch effects.
function [brs] = batchVarSeeker()
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];

	iters = 30;

	addpath analyze;

	bas = [];
	for i = [1:length(measures)]
		bas = [bas BatchAnalyzer(sprintf('Increase %s', measures(i)), iters, 3, [scaleVariance(canValues, 2.0, i); japValues; porValues], labels)];
		bas = [bas BatchAnalyzer(sprintf('Decrease %s', measures(i)), iters, 3, [scaleVariance(canValues, 0.5, i); japValues; porValues], labels)];
	end

	num = length(bas);
	str = strings(1,num);
	cri_mean = zeros(1,num);
	cri_std = zeros(1,num);
	nmi_mean = zeros(1,num);
	nmi_std = zeros(1,num);

	for i = 1:num
		ba = bas(i);
		calculateBatch(ba);
		str(i) = ba.Name;
		cri_mean(i) = mean(ba.CRI);
		cri_std(i) = std(ba.CRI);
		nmi_mean(i) = mean(ba.NMI);
		nmi_std(i) = std(ba.NMI);
	end

	rmpath analyze;

	printBatchResults(str, cri_mean, cri_std, nmi_mean, nmi_std);
end

function printBatchResults(str, cri_mean, cri_std, nmi_mean, nmi_std)
	strs = pad(str);
	fprintf('%s ,  CRI , CRIstd  ,  NMI , NMIstd  \n', pad("Name", strlength(strs(1))));
	fprintf('%s , -----,-------- , -----,-------- \n', strrep(pad(" ", strlength(strs(1))), " ", "-"));
	for i=1:length(strs)
		fprintf('%s , % .3f , %.3f , % .3f , %.3f \n', strs(i), cri_mean(i), cri_std(i), nmi_mean(i), nmi_std(i));
	end
end

function [vals] = scaleVariance(vals, stdScale, colInd)
	mns = mean(vals(:,colInd));
	vals(:,colInd) = bsxfun(@times, vals(:,colInd) - mns, stdScale) + mns;
end
