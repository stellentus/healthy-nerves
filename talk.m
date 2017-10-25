% talk prints and displays everything for the talk
function talk(dataType)
	shouldDeleteNaN = true;

	addpath import;
	valuesLeg = mefimport(pathFor('leg'), shouldDeleteNaN);
	valuesLegSCI = mefimport(pathFor('legSCI'), shouldDeleteNaN);
	rmpath import;

	addpath poster;
	[coefforth, meanorth] = transform(valuesLeg);
	rmpath poster;

	component = 1;

	score1 = valuesLeg*coefforth-meanorth;

	hold on;

	colors = get(gca,'colororder');
	colorMod = length(colors);

	for i = 1:size(score1, 1)
		color = colors(mod(i, colorMod)+1, :);
		plot(score1(i,component), score1(i,component+1), '.', 'Color', [.745 .706 .549], 'MarkerSize', 20);
	end

	scoreSCI = valuesLegSCI*coefforth-meanorth;
	for i = 1:size(scoreSCI, 1)
		plot(scoreSCI(i,component), scoreSCI(i,component+1), 'p', 'Color', [0 .384 .192], 'MarkerSize', 20, 'MarkerFaceColor', 'black');
		plot(scoreSCI(i,component), scoreSCI(i,component+1), 'o', 'Color', [0 .384 .192], 'MarkerSize', 20);
	end

	xlabel(sprintf('Component %d', component), 'Color', [0 .384 .192]);
	ylabel(sprintf('Component %d', component+1), 'Color', [0 .384 .192]);
	title('Healthy vs SCI (CP Nerve)', 'FontSize', 24, 'Color', [0 .384 .192]);
end
