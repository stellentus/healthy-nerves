% sciClustering attempts to print clustered SCI results
function sciClustering(name1, values1, participants1, valuesSCI, participantsSCI, component, markersize)
	[coefforth, meanorth] = transform(values1);

	score1 = values1*coefforth-meanorth;

	figure;
	hold on;

	colors = get(gca,'colororder');
	colorMod = length(colors);

	for i = 1:size(score1, 1)
		color = colors(mod(i, colorMod)+1, :);
		h = plot(score1(i,component), score1(i,component+1), '.', 'Color', color);
		if nargin == 7
			set(h, 'markersize', markersize);
		end
	end

	scoreSCI = valuesSCI*coefforth-meanorth;
	for i = 1:size(scoreSCI, 1)
		h = plot(scoreSCI(i,component), scoreSCI(i,component+1), '*k');
		label(h, participantsSCI(i));
		if nargin == 7
			set(h, 'markersize', markersize);
		end
	end

	xlabel(sprintf('Component %d', component));
	ylabel(sprintf('Component %d', component+1));
	title(sprintf('Healthy vs SCI Leg (Components %d and %d)', component, component+1));
end
