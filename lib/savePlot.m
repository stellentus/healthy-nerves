% savePlot saves a plot, tightening its edges if desired.
% dirPath should be a character array, not a string.
% tsString is optional. If not provided, it will be calculated.
function savePlot(fig, shouldTighten, dirPath, filename, tsString)
	if nargin < 5
		tsString = sprintf('%02d-%02d-%02d-%02d-%02d-%02.0f', clock);
	end

	if shouldTighten
		tightenPlot();
	end

	[~,~] = mkdir(dirPath); % Read and ignore returns to suppress warning if dir exists.
	if dirPath(end) ~= '/'
		dirPath = strcat(dirPath, '/');
	end
	pathstr = sprintf('%s%s-%s', dirPath, filename, tsString);

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));

	% Also save without timestamp
	copyfile(strcat(pathstr, '.png'), strcat('img/stats/', filename, '.png'));
end

% tightenPlot ensures the plot boundaries are tight (for saving).
function tightenPlot()
	ax = gca;
	outerpos = ax.OuterPosition;
	ti = ax.TightInset;
	left = outerpos(1) + ti(1);
	bottom = outerpos(2) + ti(2);
	ax_width = outerpos(3) - ti(1) - ti(3);
	ax_height = outerpos(4) - ti(2) - ti(4);
	ax.Position = [left bottom ax_width ax_height];
end
