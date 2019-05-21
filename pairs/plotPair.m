function plotPair(name, values, labels, measures, idx1, idx2, newFig)
	if nargin < 7
		newFig = false;
	end

	if newFig
		filename = sprintf("scatter-%d-%d", idx1, idx2);

		[~,~] = mkdir('img/pairs'); % Read and ignore returns to suppress warning if dir exists.
		pathstr = sprintf('img/pairs/%s-%d-%d-%d-%d%d%2.0f', filename, clock);

		fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);
		markSize = 30;
	else
		markSize = 10;
	end

	colors = [193,27,36; 0,73,137; 43,111,0]/256;

	hold on;
	for col=1:3
		val = values(labels == col, :);

		% Plot scatters
		plot(val(:, idx1), val(:, idx2), '.', 'color', colors(col, :), 'MarkerSize', markSize);

		% Plot confidence ellipses
		plotEllipse([val(:, idx1), val(:, idx2)], colors(col, :), 2);
	end

	% Plot overall confidence ellipse
	plotEllipse([values(:, idx1), values(:, idx2)], 'k', 3);

	title(name);
	xlabel(measures(idx1));
	ylabel(measures(idx2));

	if newFig
		savefig(fig, strcat(pathstr, '.fig'), 'compact');
		saveas(fig, strcat(pathstr, '.png'));
		copyfile(strcat(pathstr, '.png'), strcat('img/pairs/', filename, '.png')); % Also save without timestamp
	end
end

function plotEllipse(data, colr, linewidth, ciPercent)
	if nargin < 4
		ciPercent = 0.95; % 95% confidence interval
	end

	[eigvec, eigval] = eig(cov(data), 'vector');

	% Create an ellipse with a size based on the eigenvalues
	theta_grid = linspace(0, 2*pi);
	ellipseMax = sqrt(max(eigval)) * cos(theta_grid);
	ellipseMin = sqrt(min(eigval)) * sin(theta_grid);

	% Scale and rotate the ellipse, then shift by the mean
	ellipse = sqrt(chi2inv(ciPercent, 2)) * (eigvec * [ellipseMin; ellipseMax])' + mean(data);

	plot(ellipse(:, 1), ellipse(:, 2), '-', 'color', colr,'LineWidth', linewidth)
end
