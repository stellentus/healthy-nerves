%% ddScoresForPath calculates how likely each point is an outlier.
function [w] = ddScoresForPath(inliers, threshold, alg)
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
end
