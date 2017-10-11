% graphVariance plots the variance accounted for by PCA
function graphVariance(dataType)
	deleteNaN = true;
	alg = 'svd';

	[values, participants, measures] = loadData(dataType, deleteNaN);

	% figure;
	[~, ~, ~, ~, explained] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	% Turn it into a cumulative graph
	for i = 2:length(explained)
		explained(i) = explained(i-1) + explained(i);
	end

	figure;
	hold on;

	% Plot data with (0,0)
	plot([0:length(explained)], [0; explained]);

	% Add labels and set axis
	fontSize = 18;
	xlabel('Number of Factors', 'FontSize', fontSize);
	ylabel('Variance Accounted For (%)', 'FontSize', fontSize);
	title('Variance Accounted for By Factors (Leg)', 'FontSize', fontSize);
	axis([0 length(explained) 0 100]);

	% Add lines at 70 and 85
	plotLines(explained, 69.5);
	plotLines(explained, 84.5);
end

function plotLines(explained, val)
	fct = factorAboveValue(explained, val);
	plot([fct, fct], [0 explained(fct)]);
	h = plot([0, fct], [explained(fct) explained(fct)]);
	label(h, sprintf('%d factors: %.0f%%', fct, explained(fct)));
end

function factor = factorAboveValue(explained, val)
	indices = find(explained > val);
	factor = indices(1);
end

