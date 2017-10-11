% graphVariance plots the variance accounted for by PCA
function graphVariance()
	deleteNaN = true;
	alg = 'svd';

	figure;
	hold on;

	lenArm = graphOneVariance('arm', deleteNaN, alg);
	lenLeg = graphOneVariance('leg', deleteNaN, alg);

	% Add labels and set axis
	fontSize = 16;
	xlabel('Number of Factors', 'FontSize', fontSize+2);
	ylabel('Variance Accounted For (%)', 'FontSize', fontSize);
	title('Variance Accounted for By Factors', 'FontSize', fontSize);
	axis([0 max([lenArm lenLeg]) 0 100]);
end

function len = graphOneVariance(dataType, deleteNaN, alg)
	[values, participants, measures] = loadData(dataType, deleteNaN);

	% figure;
	[~, ~, ~, ~, explained] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);
	len = length(explained);

	% Turn it into a cumulative graph
	for i = 2:len
		explained(i) = explained(i-1) + explained(i);
	end

	% Plot data with (0,0)
	plot([0:len], [0; explained], 'b');

	% Add lines at 70 and 85
	plotLines(explained, 69.5, 'r');
	plotLines(explained, 84.5, 'm');
end

function plotLines(explained, val, linespec)
	fct = factorAboveValue(explained, val);
	plot([fct, fct], [0 explained(fct)], linespec);
	h = plot([0, fct], [explained(fct) explained(fct)], linespec);
	label(h, sprintf('%d factors: %.0f%%', fct, explained(fct)));
end

function factor = factorAboveValue(explained, val)
	indices = find(explained > val);
	factor = indices(1);
end

