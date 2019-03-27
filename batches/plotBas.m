% plotBas is used to print a table and plot an array of BatchAnalyzer
function plotBas(bas, filename, figtitle, args)
	if nargin < 4
		args = struct();
	end
	args = setArgs(args);
	iter = bas(1).Iters;
	sampleFraction = bas(1).SampleFraction;

	if args.printPercent < 100
		maxIndex = round(length(bas)*args.printPercent/100);
	else
		maxIndex = length(bas);
	end

	if args.printPercent < 100 || args.sort == true
		[~, ind] = sort([bas.Score_mean]);
		if strcmp(args.sortOrder, "descend")
			ind = fliplr(ind);
		end

		printBas = bas(ind(1:maxIndex));
	else
		printBas = bas;
	end

	padLen = printHeader(printBas);
	scores = zeros(length(printBas(1).Score), maxIndex); % only used by plotBoxes
	for i = 1:maxIndex
		disp(BAString(printBas(i), padLen));
		scores(:, i) = (printBas(i).Score');
	end

	if args.printPercent < 100
		% Now print the mean values for a reference point
		meanBA = BatchAnalyzer("Means", 3, []);
		meanBA.Score_mean = mean([bas.Score_mean]);
		meanBA.Score_std = mean([bas.Score_std]);
		disp(BAString(meanBA, padLen));
	end

	if args.plotBoxes
		plotBoxes(figtitle, filename, scores, printBas(1).ScoreName, [printBas.Name]');
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
	fprintf('%s , Score  ,  std  \n', pad("Name", padLen));
	fprintf('%s , ------ , ----- \n', strrep(pad(" ", padLen), " ", "-"));
end

function plotBoxes(titleLabel, filename, scores, scoreName, testNames)
	addpath lib/CategoricalScatterplot

	pathstr = sprintf('img/%s-%d-%d-%d-%d%d%2.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29);
	title(titleLabel);
	ylabel(scoreName);
	xtickangle(45)
	savefig(fig, strcat(pathstr, '.fig', 'compact'));
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/', filename, '.png')); % Also save without timestamp

	rmpath lib/CategoricalScatterplot
end
