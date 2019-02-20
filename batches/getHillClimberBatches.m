%% getHillClimberBatches returns a list of BatchAnalyzer that try to seek out a transformation that minimizes the batch effects.
function [bas] = getHillClimberBatches(iters)
	load('bin/batch-normative.mat');

	% Create a combined vector for labels (with all datasets)
	labels = [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)];

	stdScale = ones(1, size(canValues, 2));
	mnBias = zeros(1, size(canValues, 2));

	ba = BatchAnalyzer('Normative', 3, [canValues; japValues; porValues], labels, 'iters', iters);
	bas = [ba];
	bas = [bas BACopyWithValues(ba, 'Unchanged All', scaleValues([canValues; japValues; porValues], stdScale, mnBias))];
	bas = [bas BACopyWithValues(ba, 'Unchanged Can', [scaleValues(canValues, stdScale, mnBias); japValues; porValues])];
	bas = [bas BACopyWithValues(ba, 'Unchanged Jap', [canValues; scaleValues(japValues, stdScale, mnBias); porValues])];
	bas = [bas BACopyWithValues(ba, 'Unchanged Por', [canValues; japValues; scaleValues(porValues, stdScale, mnBias)])];
end

function [vals] = scaleValues(vals, stdScale, mnBias)
	mns = mean(vals);
	vals = bsxfun(@times, vals - mns, stdScale) + mns + mnBias;
end
