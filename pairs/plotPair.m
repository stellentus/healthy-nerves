function plotPair(name, values, labels, measures, idx1, idx2)
	filename = sprintf("scatter-%d-%d", idx1, idx2);

	[~,~] = mkdir('img/pairs'); % Read and ignore returns to suppress warning if dir exists.
	pathstr = sprintf('img/pairs/%s-%d-%d-%d-%d%d%2.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	colors = [193,27,36; 0,73,137; 43,111,0]/256;

	hold on;
	for col=1:3
		val = values(labels == col, :);
		plot(val(:, idx1), val(:, idx2), '.', 'color', colors(col, :), 'MarkerSize', 30);
	end

	title(name);
	xlabel(measures(idx1));
	ylabel(measures(idx2));

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/pairs/', filename, '.png')); % Also save without timestamp
end
