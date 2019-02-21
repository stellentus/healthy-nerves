function clusters = linkageCluster(values, groups)
	% This is deterministic
	Z = linkage(values, 'ward');
	clusters = cluster(Z, 'Maxclust', groups);
end
