% plotBas is used to print a table and plot an array of BatchAnalyzer
function plotBas(bas, args)
	if nargin < 2
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
		if strcmp(args.sortStat, "HEL")
			[~, ind] = sort([bas.HEL_mean]);
		elseif strcmp(args.sortStat, "CRI")
			[~, ind] = sort(abs([bas.CRI_mean]));
		else
			[~, ind] = sort([bas.NMI_mean]);
		end
		if strcmp(args.sortOrder, "descend")
			ind = fliplr(ind);
		end

		printBas = bas(ind(1:maxIndex));
	else
		printBas = bas;
	end

	padLen = printHeader(printBas, args.printHell);
	scores = zeros(length(printBas(1).NMI), maxIndex); % only used by plotBoxes
	for i = 1:maxIndex
		disp(BAString(printBas(i), padLen));
		scores(:, i) = (printBas(i).NMI');
	end

	if args.printPercent < 100
		% Now print the mean values for a reference point
		meanBA = BatchAnalyzer("Means", 3, []);
		meanBA.HEL_mean = mean([bas.HEL_mean]);
		meanBA.HEL_std = mean([bas.HEL_std]);
		meanBA.CRI_mean = mean([bas.CRI_mean]);
		meanBA.CRI_std = mean([bas.CRI_std]);
		meanBA.NMI_mean = mean([bas.NMI_mean]);
		meanBA.NMI_std = mean([bas.NMI_std]);
		disp(BAString(meanBA, padLen));
	end

	if args.plotBoxes
		plotBoxes(sprintf('Batch Effect Measures (%d iters; size %f)', iter, sampleFraction), scores, [printBas.Name]');
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
	if ~isfield(args, 'sortStat')
		args.sortStat = 'NMI';
	end
	if ~isfield(args, 'sortOrder')
		args.sortOrder = 'ascend';
	end
	if ~isfield(args, 'printHell')
		args.printHell = false;
	end
end

function padLen = printHeader(bas, printHell)
	% Get length of longest string for padding purposes
	padLen = 0;
	for i = 1:length(bas)
		slen = strlength(bas(i).Name);
		if slen > padLen
			padLen = slen;
		end
	end

	measStr = ', CRI    ,CRIstd , NMI    ,NMIstd ';
	measNum = 2;
	if printHell
		measStr = strcat(measStr, ', HEL    ,HELstd ');
		measNum = measNum + 1;
	end

	% Print the table header
	fprintf('%s %s\n', pad("Name", padLen), measStr);
	fprintf('%s %s\n', strrep(pad(" ", padLen), " ", "-"), repmat(', ------ , ----- ', 1, measNum));
end

function plotBoxes(titleLabel, scores, testNames)
	addpath lib/CategoricalScatterplot

	pathstr = sprintf('img/batbox-%d-%d-%d-%d%d%2.0f', clock);

	fig = figure('DefaultAxesFontSize', 18);

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29);
	title(titleLabel);
	xlabel('Group');
	ylabel('NMI');
	xtickangle(45)
	savefig(fig, strcat(pathstr, '.fig', 'compact'));
	saveas(fig, strcat(pathstr, '.png'));

	rmpath lib/CategoricalScatterplot
end
