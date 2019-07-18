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
