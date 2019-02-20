%% getVarSeekerBatches returns a list of BatchAnalyzer that try to seek out the indices with the strongest variance-induced batch effects.
function [bas] = getVarSeekerBatches(iters)
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];

	ba = BatchAnalyzer('Normative', 3, [canValues; japValues; porValues], labels, 'iters', iters);
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
end

function [vals] = scaleVariance(vals, stdScale, colInd)
	% The variance is scaled by the number of columns being modified. This makes the overall change more comparable.
	stdScale = (stdScale-1)/sqrt(length(colInd))+1;
	mns = mean(vals(:,colInd));
	vals(:,colInd) = bsxfun(@times, vals(:,colInd) - mns, stdScale) + mns;
end
