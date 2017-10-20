function correlations(values1, values2, participants1, participants2)
	[ind1, ind2] = commonIndices(participants1, participants2);
	values1 = values1(ind1, :);
	values2 = values2(ind2, :);

	printCorr(values1, values2, 'original');
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
