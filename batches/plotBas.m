% plotBas is used to print a table and plot an array of BatchAnalyzer
function plotBas(bas, filename, figtitle, args)
	if nargin < 4
		args = struct();
	end
	args = setArgs(args);
	iter = bas(1).Iters;

	padLen = printHeader(bas);
	scores = zeros(length(bas(1).Score), length(bas)*2); % only used by plotBoxes
	for i = 1:length(bas)
		disp(BAString(bas(i), padLen));
		scores(:, 2*i-1) = (bas(i).Score'/bas(i).BaselineScore_mean);
		scores(:, 2*i) = (bas(i).BaselineScore'/bas(i).BaselineScore_mean);
	end

	if args.plotBoxes
		% plotNames = repmat(["BVI", "max"], 1, length(bas));
		plotBoxes(figtitle, filename, scores, 'Homogeneity (%)', []);
		ylim([0 1.15])
		% set(gca, 'xaxisLocation', 'top');

		for i = 1:length(bas)
			% Add a label with the homogeneity score.
			textLabel = sprintf("%2.0f%%\nHomogeneous\n\np=%s", bas(i).Homogeneity_mean*100, PString(bas(i)));
			x = 2*i - 0.5;
			y = 0.6;
			if bas(i).Homogeneity_mean < 0.50 && bas(i).Homogeneity_mean > .1
				y = 0.9;
			end
			text(x, y, textLabel, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap', 'FontSize', 18);

			% Add a label with the name of this element.
			pos = get(gca, 'Position');
			namePos = [(x -0.9 + abs(min(xlim)))/diff(xlim) * pos(3) + pos(1), (0 - min(ylim))/diff(ylim) * pos(4) + pos(2), 1.8/diff(xlim) * pos(3), 0];
			ta1 = annotation('textbox', namePos, 'string', bas(i).Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap', 'FontSize', 18);
		end
	end
end

% setArgs sets any missing arguments. It might cause issues if the incoming 'args' is read-only.
function [args] = setArgs(args)
	if ~isfield(args, 'printPercent')
		args.printPercent = 100;
	end
	if ~isfield(args, 'sort')
		args.sort = false;
	end
	if ~isfield(args, 'sortOrder')
		args.sortOrder = 'ascend';
	end
	if ~isfield(args, 'plotBoxes')
		args.plotBoxes = true;
	end
	if ~isfield(args, 'LadderLines')
		args.LadderLines = false;
	end
end

function padLen = printHeader(bas)
	% Get length of longest string for padding purposes
	padLen = 0;
	for i = 1:length(bas)
		slen = strlength(bas(i).Name);
		if slen > padLen
			padLen = slen;
		end
	end

	% Print the table header
	fprintf('%s , Score  ,  std  , Base   ,  std  , Homog ,  PVal  \n', pad("Name", padLen));
	fprintf('%s , ------ , ----- , ------ , ----- , ----- , ------ \n', strrep(pad(" ", padLen), " ", "-"));
end

function plotBoxes(titleLabel, filename, scores, scoreName, testNames)
	addpath lib/CategoricalScatterplot

	pathstr = sprintf('img/batch/%s-%d-%d-%d-%d%d%2.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true);
	title(titleLabel);
	ylabel(scoreName);

	savefig(fig, strcat(pathstr, '.fig', 'compact'));
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/batch/', filename, '.png')); % Also save without timestamp

	rmpath lib/CategoricalScatterplot
end
