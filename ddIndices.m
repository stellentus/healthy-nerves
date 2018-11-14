%% ddIndices gives group indices for the requested algorithm.
%% This is probably totally useless. I wrote it and realized I don't need it.
function [scores, thresholds] = ddIndices(values, labels, targetIndex, threshold, alg)
	if nargin < 5
		alg = 'mog';
		if nargin < 4
			threshold = 0.01;
		end
	end

	addpath import;
	inliers = target_class(prdataset(values, labels), targetIndex);
	rmpath import;

	% Calculate scores
	scrTh = +(values * ddModel(inliers, threshold, alg));
	scores = scrTh(:, 1);
	thresholds = scrTh(:, 2);
end
