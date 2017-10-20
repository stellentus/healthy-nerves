function correlations(measures, values1, values2, participants1, participants2)
	[ind1, ind2] = commonIndices(participants1, participants2);
	values1 = values1(ind1, :);
	values2 = values2(ind2, :);

	printCorr(measures, values1, values2, 'original');
end

% correlations prints the list of measurements that are correlated between two measures
function printCorr(measures, values1, values2, name)
	[matchCorr, matchP] = corr(values1, values2);
	isCorr = diag(matchP<.005);

	corMeas = [];
	for i = 1:length(isCorr)
		if isCorr(i)
			corMeas = [corMeas; measures(i)];
		end
	end

	if isempty(corMeas)
	else
		disp(sprintf('The following %d measures are correlated between the %s datasets: ', length(corMeas), name) + strjoin(corMeas, ', ') + '.');
	end
end
