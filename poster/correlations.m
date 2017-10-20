function correlations(values1, values2, participants1, participants2)
	[ind1, ind2] = commonIndices(participants1, participants2);
	values1 = values1(ind1, :);
	values2 = values2(ind2, :);

	printCorr(values1, values2, 'original');

	[~, score1] = pca(values1, 'VariableWeights', 'variance');
	[~, score2] = pca(values2, 'VariableWeights', 'variance');
	printCorr(score1, score2, 'pca');

	[coefforth, meanorth] = transform(values1);
	score1 = values1*coefforth-meanorth;
	score2 = values2*coefforth-meanorth;
	printCorr(score1, score2, 'transformed');
end

% correlations prints the list of measurements that are correlated between two measures
function printCorr(values1, values2, name)
	[matchCorr, matchP] = corr(values1, values2);
	numCorr = sum(diag(matchP<.005));

	if numCorr==0
		disp(sprintf('No measures are correlated between the %s datasets.', name));
	else
		disp(sprintf('%d measures are correlated between the %s datasets.', sum(numCorr), name));
	end
end
