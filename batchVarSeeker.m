%% batchVarSeeker tries to seek out the indices with the strongest variance-induced batch effects.
function [brs] = batchVarSeeker()
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];

	iters = 30;

	addpath analyze;

	ba = BatchAnalyzer('Normative', iters, 3, [canValues; japValues; porValues], labels);
	bas = [ba];
	for i = [1:length(measures)]
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s', measures(i)), [scaleVariance(canValues, 0.5, i); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s', measures(i)), [scaleVariance(canValues, 2.0, i); japValues; porValues])];
	end
	for plt = ["SR" "IV" "QT" "TEd" "TEh" "Meta" "RC" "all"];
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s', plt), [scaleVariance(canValues, 0.5, indicesForPlot(plt)); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s', plt), [scaleVariance(canValues, 2.0, indicesForPlot(plt)); japValues; porValues])];
	end
	for channel = ["Ci" "Cmy" "Gmy" "GKf" "GKfi" "GKir" "GKs" "GLk" "GLki" "PNa" "PNap" "vleak" "all"];
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s', channel), [scaleVariance(canValues, 0.5, indicesForChannel(channel)); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s', channel), [scaleVariance(canValues, 2.0, indicesForChannel(channel)); japValues; porValues])];
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

function [inds] = indicesForPlot(plot)
	switch plot
		case "SR"
			inds = [1,4,5];
		case "IV"
			inds = [6,7,25];
		case "QT"
			inds = [2,3];
		case "TEd"
			inds = [22,11,17,18,20,24,23];
		case "TEh"
			inds = [10,19,21,27,28];
		case "Meta"
			inds = [8,14,15,16];
		case "RC"
			inds = [26,9,29,30,31,12,13];
		case "all"
			inds = [1:31]; % includes all of the above plots
		otherwise
			inds = [];
			warning("Could not get indices");
	end
end

function [inds] = indicesForChannel(channel)
	% This is just based on my visual inspection of the available data from a page of ±40% plots Dr. Jones gave me.
	switch channel
		case "Ci"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,19,27,10,28,21];
		case "Cmy"
			inds = [9,29,25,10];
		case "Gmy"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,19,27,10,28,21];
		case "GKf"
			inds = [9,26,29,30,31,12,6,7,11,22,17,24,18,23,20];
		case "GKfi"
			inds = [26,30,31,12,6,7,22,17,24,18,23,20,10];
		case "GKir"
			inds = [30,12,25,6,7,22,17,24,18,20,27,10,21];
		case "GKs"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,20,27,10,21];
		case "GLk"
			inds = [25,6,7,22,23,27,10,21];
		case "GLki"
			inds = [25,6,7,22,17,24,18,27,10,21];
		case "PNa"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,10];
		case "PNap"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,27];
		case "vleak"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,20,19,27,10,28,21];
		case "all"
			inds = [6:7,9:13,17:31]; % includes all of the above channels
		otherwise
			inds = [];
			warning("Could not get indices");
	end
end
