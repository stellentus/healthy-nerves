%% plotImportantIndices plots the indices causing the most batching. It assumes it is receiving a bas calculated by getDeletedFeatureBatches.
function plotImportantIndices(bas, measures)
	scores = zeros(1,31);
	count = 0;
	for i=2:length(bas)
		str = char(bas(i).Name);
		str = str(9:end-1);
		vals = sscanf(str, '%f');
		for j=1:length(vals)
			scores(vals(j)) = scores(vals(j)) + bas(i).CRI_mean;
			count = count + 1;
		end
	end

	% Now normalize by subtracting the CRI when all inds are included
	scores = scores - bas(1).CRI_mean * count / 31;

	[~, ind] = sort(scores);

	figref = figure();
	bar(scores(ind));
	xticklabels(measures(ind))
	xticks(1:1:length(ind))
	xtickangle(45)
	title("Measures Causing BE (Worst on Left)")
	ylabel("Average change to CRI when index is removed")

	addpath lib;
	savePlot(figref, false, 'img/batch', 'impind');
	rmpath lib;
end

% 18 TEd(90-100ms)
% 25 Hyperpol. I/V slope
% 02 Strength-duration time constant (ms)
% 14 Age (years)
% 11 TEd(10-20ms)
