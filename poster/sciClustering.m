% sciClustering attempts to print clustered SCI results
function sciClustering(name1, values1, participants1, name2, values2, participants2, valuesSCI, component)
	alg = 'svd';
	components = component:component+1;

	[coeff1, score1] = pca(values1, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforth1 = inv(diag(std(values1)))*coeff1;
	score2 = zscore(values2)*coefforth1;

	[ind1, ind2] = commonIndices(participants1, participants2);

	figure;
	hold on;

	for i = 1:length(ind1)
		plot(score1(i,components), score2(i,components), '-*');
	end

	scoreSCI = zscore(valuesSCI)*coefforth1;
	plot(scoreSCI(:,components), 'xk');
end
