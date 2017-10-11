% sciClustering attempts to print clustered SCI results
function sciClustering(name1, values1, participants1, name2, values2, participants2, valuesSCI)
	alg = 'svd';

	[coeff1, score1] = pca(values1, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforth1 = inv(diag(std(values1)))*coeff1;
	score2 = zscore(values2)*coefforth1;

	[ind1, ind2] = commonIndices(participants1, participants2);

	figure;
	hold on;

	for i = 1:length(ind1)
		plot(score1(i,1:2), score2(i,1:2), '-*');
	end

	scoreSCI = zscore(valuesSCI)*coefforth1;
	plot(scoreSCI(:,1:2), 'xk');
end
