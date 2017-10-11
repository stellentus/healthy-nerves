% graphVariance plots the variance accounted for by PCA
function graphVariance()
	dataType = 'leg';
	deleteNaN = true;
	alg = 'svd';

	[values, participants, measures] = loadData(dataType, deleteNaN);

	% figure;
	[~, ~, ~, ~, explained] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	% Turn it into a cumulative graph
	for i = 2:length(explained)
		explained(i) = explained(i-1) + explained(i);
	end

	plot([0:length(explained)], [0; explained]); % Plot with (0,0)
	xlabel('Number of Factors');
	ylabel('Variance Accounted For (%)');
	title('Variance Accounted for By Factors (Leg)');
	axis([0 length(explained) 0 100]);
end
