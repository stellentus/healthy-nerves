%% batchVarSeeker tries to seek out the indices with the strongest variance-induced batch effects.
function [brs] = batchVarSeeker()
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];

	iters = 30;

	addpath batches;

	ba = BatchAnalyzer('Normative', iters, 3, [canValues; japValues; porValues], labels);
	bas = [ba];
	for i = [1:length(measures)]
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s', measures(i)), [scaleVariance(canValues, 0.1, i); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s', measures(i)), [scaleVariance(canValues, 10, i); japValues; porValues])];
	end
	for plt = ["SR" "IV" "QT" "TEd" "TEh" "Meta" "RC" "all"];
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s plot', plt), [scaleVariance(canValues, 0.1, indicesForPlotNoTE20(plt)); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s plot', plt), [scaleVariance(canValues, 10, indicesForPlotNoTE20(plt)); japValues; porValues])];
	end
	for channel = ["Ci" "Cmy" "Gmy" "GKf" "GKfi" "GKir" "GKs" "GLk" "GLki" "PNa" "PNap" "vleak" "all"];
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s channel', channel), [scaleVariance(canValues, 0.1, indicesForChannelNoTE20(channel)); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s channel', channel), [scaleVariance(canValues, 10, indicesForChannelNoTE20(channel)); japValues; porValues])];
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

	rmpath batches;

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
	% The variance is scaled by the number of columns being modified. This makes the overall change more comparable.
	stdScale = (stdScale-1)/sqrt(length(colInd))+1;
	mns = mean(vals(:,colInd));
	vals(:,colInd) = bsxfun(@times, vals(:,colInd) - mns, stdScale) + mns;
end
