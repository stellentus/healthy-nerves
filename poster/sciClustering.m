% sciClustering attempts to print clustered SCI results
function sciClustering(name1, values1, participants1, name2, values2, participants2, valuesSCI, participantsSCI, component)
	coeff = pca(values1, 'VariableWeights', 'variance');
	coefforth = inv(diag(std(values1)))*coeff./std(values1)';

	meanorth = mean(values1)*coefforth;
	score1 = values1*coefforth-meanorth;
	score2 = values2*coefforth-meanorth;

	[ind1, ind2] = commonIndices(participants1, participants2);

	figure;
	hold on;

	colors = get(gca,'colororder');
	colorMod = length(colors);

	for i = 1:length(ind1)
		color = colors(mod(i, colorMod)+1, :);
		plot(score1(i,component), score1(i,component+1), '.', 'Color', color);
	end

	scoreSCI = valuesSCI*coefforth-meanorth;
	for i = 1:size(scoreSCI, 1)
		h = plot(scoreSCI(i,component), scoreSCI(i,component+1), '*k');
		label(h, participantsSCI(i));
	end

	xlabel(sprintf('Component %d', component));
	ylabel(sprintf('Component %d', component+1));
	title(sprintf('Healthy vs SCI Leg (Components %d and %d)', component, component+1));
end
