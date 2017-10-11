% correlations prints the list of measurements that are correlated between arm and leg.
function correlations(measures, cDataMatched, mDataMatched)
	[matchCorr, matchP] = corr(cDataMatched, mDataMatched);
	isCorr = diag(matchP<.05);

	corMeas = [];
	for i = 1:length(isCorr)
		if isCorr(i)
			corMeas = [corMeas; measures(i)];
		end
	end

	if isempty(corMeas)
		disp('No measures are correlated between the datasets.')
	else
		disp(sprintf('The following %d measures are correlated between the datasets: ', length(corMeas)) + strjoin(corMeas, ', ') + '.');
	end
end
