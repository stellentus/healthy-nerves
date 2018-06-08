%% ddModel calculates how likely each point is an outlier.
function [w] = ddModel(inliers, threshold, alg)
	% Train the model
	switch alg
	case 'mog'
		w = mog_dd(inliers, threshold, 5);  % Number of gaussians
	case 'gauss'
		% Misses most SCI
		w = gauss_dd(inliers, threshold);
	case 'pca'
		% Misses most SCI
		w = pca_dd(inliers, threshold, 7);  % Number of PCA components
	case 'kmeans'
		% Misses a rat and gets few SCI
		w = kmeans_dd(inliers, threshold, 5);  % Number of clusters
	case 'parzen'
		% Fantastic (101/263 SCI)
		w = parzen_dd(inliers, threshold);
	case 'autoenc'
		% Missed 2 rats and most SCI
		w = autoenc_dd(inliers, threshold, 5);  % Number of hidden units
	case 'som'
		% Misses a rat and gets 5/263 SCI
		w = som_dd(inliers, threshold);
	case 'svdd'
		% Everything is an outlier. Even 346/400 healthy are outliers.
		w = svdd(inliers, threshold, 5);  % Width parameter
	case 'lofdd'
		% Misses most SCI
		w = lofdd(inliers, threshold, 5);  % Width parameter
	otherwise
		error('Algorithm not set')
	end
end
