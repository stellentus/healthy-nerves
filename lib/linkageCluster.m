function clusters = linkageCluster(values, groups)
	% This is deterministic
	% Z = linkage(values, 'single');
	% Z = linkage(values, 'complete');
	% Z = linkage(values, 'average');
	% Z = linkage(values, 'weighted');
	% Z = linkage(values, 'centroid'); % Warning: Non-monotonic cluster tree -- the centroid linkage is probably not appropriate.
	% Z = linkage(values, 'median'); % Warning: Non-monotonic cluster tree -- the median linkage is probably not appropriate.
	Z = linkage(values, 'ward');
	clusters = cluster(Z, 'Maxclust', groups);
end
