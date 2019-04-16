% plotBas is used to print a table and plot an array of BatchAnalyzer
function plotBas(bas, filename, figtitle, args)
	if nargin < 4
		args = struct();
	end
	args = setArgs(args);
	iter = bas(1).Iters;

	padLen = printHeader(bas);
	scores = zeros(length(bas(1).Score), length(bas)*2); % only used by plotBoxes
	names = [];
	for i = 1:length(bas)
		disp(BAString(bas(i), padLen));
		scores(:, 2*i-1) = (bas(i).Score'/bas(i).BaselineScore_mean);
		scores(:, 2*i) = (bas(i).BaselineScore'/bas(i).BaselineScore_mean);
		names = [names; bas(i).Name; bas(i).Name + " RAND"];
	end

	if args.plotBoxes
		figure;
		plotBoxes(figtitle, filename, scores, 'NVI', names);
		yl = ylim;
		if yl(1) > 0
			yl(1) = 0;
		end
		if yl(2) < 1
			yl(2) = 1;
		end
		ylim(yl)
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
	fprintf('%s , Score  ,  std  , Base   ,  std  , Batch ,  PVal  \n', pad("Name", padLen));
	fprintf('%s , ------ , ----- , ------ , ----- , ----- , ------ \n', strrep(pad(" ", padLen), " ", "-"));
end

function plotBoxes(titleLabel, filename, scores, scoreName, testNames)
	addpath lib/CategoricalScatterplot

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true);
	title(titleLabel);
	ylabel(scoreName);
	xtickangle(45)

	rmpath lib/CategoricalScatterplot
end
