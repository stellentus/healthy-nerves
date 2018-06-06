%% ddScoresForPath loads all Excel files and filters them based on names to get 'rat'
%% data and 'SCI' data. It marks the rest as targets, and calculates how likely each
%% rat and SCI point is an outlier.
function [data] = ddScoresForPath(threshold, alg, nanMethod, folderpath)
	if nargin < 4
		folderpath = 'data';
		if nargin < 3
			nanMethod = 'Mean';
			if nargin < 2
				alg = 'mog';
				if nargin < 1
					threshold = 0.1;
				end
			end
		end
	end

	addpath import;
	[inliers, data] = importPRDataset(nanMethod, folderpath);
	rmpath import;

	% Train the model
	switch alg
	case 'mog'
		w = mog_dd(inliers, threshold, 5);  % Number of gaussians
	case 'gauss'
		w = gauss_dd(inliers, threshold);
	case 'pca'
		w = pca_dd(inliers, threshold, 7);  % Number of PCA components
	case 'kmeans'
		w = kmeans_dd(inliers, threshold, 5);  % Number of clusters
	case 'parzen'
		w = parzen_dd(inliers, threshold);
	case 'autoenc'
		w = autoenc_dd(inliers, threshold, 5);  % Number of hidden units
	case 'som'
		w = som_dd(inliers, threshold);
	case 'svdd'
		w = svdd(inliers, threshold, 5);  % Width parameter
	case 'lofdd'
		w = lofdd(inliers, threshold, 5);  % Width parameter
	otherwise
		error('Algorithm not set')
	end
	scores = +(data.values * w);
	data.scores = scores(:, 1);
	data.thresholds = scores(:, 2);
end
