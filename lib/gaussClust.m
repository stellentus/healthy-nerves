function clus = gaussClust(X, k)
	try
		gmfit = fitgmdist(X, k, 'CovarianceType', 'diagonal', 'SharedCovariance', true);
		clus = cluster(gmfit, X);
	catch e
		warning('Falling back to linkage cluster');
		clus = linkageCluster(X, k);
	end
end
