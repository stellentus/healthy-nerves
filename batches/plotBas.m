% plotBas is used to print a table and plot an array of BatchAnalyzer
function plotBas(bas, filename, figtitle, args)
	if nargin < 4
		args = struct();
	end
	args = setArgs(args);
	iter = bas(1).Iters;

	% Get length of longest string for padding purposes
	padLen = max(strlength([bas.Name]));
	BatchAnalyzer.printHeader(padLen);

	scores = zeros(length(bas(1).Score), length(bas)*2); % only used by plotBoxes
	for i = 1:length(bas)
		disp(BAString(bas(i), padLen));
		scores(:, 2*i-1) = (bas(i).Score'/bas(i).BaselineScore_mean);
		scores(:, 2*i) = (bas(i).BaselineScore'/bas(i).BaselineScore_mean);
	end

	if args.plotBoxes
		plotBoxes(figtitle, filename, scores, 'Homogeneity (%)', bas, args.fontSize);
	end
end

% setArgs sets any missing arguments. It might cause issues if the incoming 'args' is read-only.
function [args] = setArgs(args)
	if ~isfield(args, 'plotBoxes')
		args.plotBoxes = true;
	end
	if ~isfield(args, 'fontSize')
		args.fontSize = 18;
	end
end

function plotBoxes(titleLabel, filename, scores, scoreName, bas, fontSize)
	addpath lib/CategoricalScatterplot

	[~,~] = mkdir('img/batch'); % Read and ignore returns to suppress warning if dir exists.
	pathstr = sprintf('img/batch/%s-%02d-%02d-%02d-%02d-%02d-%02.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', fontSize, 'Position', [10 10 900 600]);

	CategoricalScatterplot(scores, [], 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true, 'MedianColor', [193,27,36]/255);
	title(titleLabel);
	ylabel(scoreName);
	ylim([0 1.15])

	for i = 1:length(bas)
		% Add a label with the homogeneity score.
		pStr = PString(bas(i));
		if pStr(1)~='<'
			pStr = strcat('=', pStr);
		end
		textLabel = sprintf("%2.0f%% Homog.\np%s", bas(i).Homogeneity_mean*100, pStr);
		x = 2*i - 0.5;
		text(x, 0.2, textLabel, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap', 'FontSize', fontSize-2);

		% Add a label with the name of this element.
		pos = get(gca, 'Position');
		namePos = [(x -0.9 + abs(min(xlim)))/diff(xlim) * pos(3) + pos(1), (0 - min(ylim))/diff(ylim) * pos(4) + pos(2), 1.8/diff(xlim) * pos(3), 0];
		ta1 = annotation('textbox', namePos, 'string', bas(i).Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap', 'FontSize', fontSize);
	end

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/batch/', filename, '.png')); % Also save without timestamp

	rmpath lib/CategoricalScatterplot
end
