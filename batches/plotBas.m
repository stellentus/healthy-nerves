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
		plotBoxes(figtitle, filename, scores, 'Homogeneity (%)', bas, args.fontSize, args.showTitle);
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
	if ~isfield(args, 'showTitle')
		args.showTitle = true;
	end
end

function plotBoxes(titleLabel, filename, scores, scoreName, bas, fontSize, showTitle)
	addpath lib/CategoricalScatterplot

	fig = figure('DefaultAxesFontSize', fontSize, 'Position', [10 10 200*length(bas) 600]);

	CategoricalScatterplot(scores, [], 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true, 'MedianColor', [193,27,36]/255);
	if showTitle
		title(titleLabel);
	end
	ylabel(scoreName);
	ylim([0 1.15]);
	xlim([0 2*length(bas)+1]);

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

	rmpath lib/CategoricalScatterplot

	addpath lib;
	savePlot(fig, false, 'img/batch', filename);
	rmpath lib;
end
