% sciClustering attempts to print clustered SCI results
function sciClustering(name1, values1, participants1, name2, values2, participants2, valuesSCI, participantsSCI, component)
	coeff1 = pca(values1, 'VariableWeights', 'variance');

	coefforth1 = inv(diag(std(values1)))*coeff1;
	score1 = zscore(values1)*coefforth1;
	score2 = zscore(values2)*coefforth1;

	[ind1, ind2] = commonIndices(participants1, participants2);

	figure;
	hold on;

	colors = get(gca,'colororder');
	colorMod = length(colors);

	for i = 1:length(ind1)
		color = colors(mod(i, colorMod)+1, :);
		plot(score1(i,component), score1(i,component+1), '.', 'Color', color);
	end

	scoreSCI = zscore(valuesSCI)*coefforth1;
	for i = 1:size(scoreSCI, 1)
		h = plot(scoreSCI(i,component), scoreSCI(i,component+1), '*k');
		label(h, participantsSCI(i));
	end

	xlabel(sprintf('Component %d', component));
	ylabel(sprintf('Component %d', component+1));
	title(sprintf('Healthy vs SCI Leg (Components %d and %d)', component, component+1));
end
