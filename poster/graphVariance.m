% graphVariance plots the variance accounted for by PCA
function graphVariance(name1, values1, name2, values2)
	deleteNaN = true;
	alg = 'svd';

	figure;
	hold on;

	lenArm = graphOneVariance(values1, name1, '-', deleteNaN, alg);
	lenLeg = graphOneVariance(values2, name2, '--', deleteNaN, alg);

	% Add labels and set axis
	fontSize = 16;
	xlabel('Number of Factors', 'FontSize', fontSize+2);
	ylabel('Variance Accounted For (%)', 'FontSize', fontSize);
	title('Variance Accounted for By Factors', 'FontSize', fontSize);
	axis([0 max([lenArm lenLeg]) 0 100]);

	legend;
end

function len = graphOneVariance(values, name, lineType, deleteNaN, alg)
	% figure;
	[~, ~, ~, ~, explained] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);
	len = length(explained);

	% Turn it into a cumulative graph
	for i = 2:len
		explained(i) = explained(i-1) + explained(i);
	end

	% Plot data with (0,0)
	plot([0:len], [0; explained], [lineType 'b'], 'DisplayName', name);

	% Add lines at 70 and 85
	plotLines(explained, 70, [lineType 'r']);
	plotLines(explained, 85, [lineType 'm']);
end

function plotLines(explained, val, linespec)
	fct = factorAboveValue(explained, val);

	h = plot([fct, fct], [0 explained(fct)], linespec);
	set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

	h = plot([0, fct], [explained(fct) explained(fct)], linespec);
	set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
	label(h, sprintf('%d factors: %.0f%%', fct, explained(fct)));
end

function factor = factorAboveValue(explained, val)
	indices = find(explained > val);
	factor = indices(1);
end

