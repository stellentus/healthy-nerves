%% getMeanSeekerBatches returns a list of BatchAnalyzer that try to seek out the indices with the strongest mean-induced batch effects.
function [bas] = getMeanSeekerBatches(iters)
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];

	ba = BatchAnalyzer('Normative', iters, 3, [canValues; japValues; porValues], labels);
	bas = [ba];
	for i = [1:length(measures)]
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s', measures(i)), [scaleMean(canValues, 0.9, i); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s', measures(i)), [scaleMean(canValues, 1.1, i); japValues; porValues])];
	end
	for plt = ["SR" "IV" "QT" "TEd" "TEh" "Meta" "RC" "all"];
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s plot', plt), [scaleMean(canValues, 0.9, indicesForPlotNoTE20(plt)); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s plot', plt), [scaleMean(canValues, 1.1, indicesForPlotNoTE20(plt)); japValues; porValues])];
	end
	for channel = ["Ci" "Cmy" "Gmy" "GKf" "GKfi" "GKir" "GKs" "GLk" "GLki" "PNa" "PNap" "vleak" "all"];
		bas = [bas BACopyWithValues(ba, sprintf('Decrease %s channel', channel), [scaleMean(canValues, -0.1, indicesForChannelNoTE20(channel)); japValues; porValues])];
		bas = [bas BACopyWithValues(ba, sprintf('Increase %s channel', channel), [scaleMean(canValues, 0.1, indicesForChannelNoTE20(channel)); japValues; porValues])];
	end
end

function [vals] = scaleMean(vals, mnScale, colInd)
	% The mean is scaled by the number of columns being modified. This makes the overall change more comparable.
	mnScale = mnScale/sqrt(length(colInd));
	mns = mean(vals(:,colInd));
	vals(:,colInd) = vals(:,colInd) + mns*mnScale;
end
