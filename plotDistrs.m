function plotDistrs()
	load("bin/batch-normative.mat");
	values = [canValues; japValues; porValues];

	close all;

	for i=1:size(values, 2)
		fig = figure('DefaultAxesFontSize', 18);
		histogram(values(:, i), 100);
		title(measures(i));
		% saveas(fig, sprintf('img/plotDistrs%02d-%02d-%02d-%02d-%02d-%02.0f.png', clock));
	end
end
