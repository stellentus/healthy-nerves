% batchDemos creates some demo plots for batch effect VI homogeneity.
function batchDemos()
	rng('default')  % For reproducibility

	mu1 = [2 3];
	sigma1 = [1 1.5; 1.5 4];

	mu2 = 2*[-5 13];
	sigma2 = 5*[4 3; 3 3.5];

	mu3 = [3 4];

	data1 = mvnrnd(mu1, sigma1, 5000);
	data2 = mvnrnd(mu2, sigma2, 5000);
	data3 = mvnrnd(mu3, sigma2, 5000);

	[~,~] = mkdir('img/batch'); % Read and ignore returns to suppress warning if dir exists.

	addpath batches;

	padLen = 4;
	BatchAnalyzer.printHeader(padLen);
	makePaperPlot("bvi-comparison", data1, data2, data3);

	BatchAnalyzer.printDivider(padLen);
	makePosterPlot("bvi-poster", data1, data2, data3);
	rmpath batches;
end

function makePosterPlot(name, data1, data2, data3)
	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 480 600]);

	plotWithRange(1, data1, data2, 500, 0, 0, 500, 30, "A");
	plotWithRange(2, data1, data2, 0, 500, 0, 500, 30, "B");
	plotWithRange(3, data1, data2, 400, 0, 100, 500, 30, "C");
	plotWithRange(4, data1, data3, 500, 0, 0, 500, 30, "D");

	saveFigureToBatchDir(name, fig);
end

function makePaperPlot(name, data1, data2, data3)
	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 480 600]);

	plotWithRange(1, data1, data2, 500, 0, 0, 500, 30, "A");
	plotWithRange(2, data1, data2, 400, 0, 100, 500, 30, "B");
	plotWithRange(3, data1, data2, 50, 450, 0, 500, 30, "C");
	plotWithRange(4, data1, data2, 0, 500, 0, 500, 30, "D");
	plotWithRange(5, data1, data3, 500, 0, 0, 500, 30, "E");
	plotWithRange(6, data1, data3, 63, 0, 63, 126, 30, "F");

	saveFigureToBatchDir(name, fig);
end

function saveFigureToBatchDir(name, fig)
	pathstr = sprintf('img/batch/%s-%02d-%02d-%02d-%02d-%02d-%02.0f',name,  clock);
	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/batch/', name, '.png')); % Also save without timestamp
end

function plotWithRange(plotId, data1, data2, n1a, n2a, n1b, n2b, iters, letterLabel)
	d1 = [data2(1:n1a,:); data1(1:n2a,:)];
	d2 = [data2((n1a+1):(n1b+n1a),:); data1((n2a+1):(n2b+n2a),:)];

	siz1 = size(d1, 1);
	siz2 = size(d2, 1);

	labels = [ones(siz1, 1); ones(siz2, 1) * 2];
	ba = BatchAnalyzer(letterLabel, 2, [d1; d2], labels, 'iters', iters);
	calculateBatch(ba);

	padLen = 4;
	disp(BAString(ba, padLen));

	par = [
		.01 .60;
		.49 .60;
		.01 .31;
		.49 .31;
		.01 .02;
		.49 .02;
	];

	if plotId ~= 0
		pos = [par(plotId, 1) par(plotId, 2) .31 .27];
		sb = subplot('Position', pos, 'Units', 'normalized');
		set(sb, 'YTick', [], 'XTick', []);
		hold on;
		plot(d1(:,1), d1(:,2), 'o', 'color', [0,73,137]/255);
		plot(d2(:,1), d2(:,2), 'x', 'color', [43,111,0]/255);
	    text(0.05, 0.95, letterLabel, 'fontweight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'cap', 'Units', 'normalized');
		pos(1) = pos(1) + 0.315;
		pos(3) = 0.12;
		subplot('Position', pos, 'Units', 'normalized');
		plotBA(ba);
		if mod(plotId, 2) == 0
			ylabel('Homogeneity (%)');
		end
	end
end

% plotBA is used to print a table and one BatchAnalyzer
function plotBA(ba)
	scores = [ba.Score'/ba.BaselineScore_mean ba.BaselineScore'/ba.BaselineScore_mean];
	plotBoxes(scores, ["Homog.", "|Max|"]);
	ylim([0 1.15])

    textLabel = sprintf("%2.0f%%\nHomog.\n\np=%s", ba.Homogeneity_mean*100, PString(ba));
	x = 1.5;
	y = 0.6;
	if ba.Homogeneity_mean < 0.50 && ba.Homogeneity_mean > .1
		y = 0.9;
	end
    text(x, y, textLabel, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap');
end

function plotBoxes(scores, testNames)
	addpath lib/CategoricalScatterplot

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true);
	set(gca, 'YAxisLocation', 'right');
	set(gca,'FontSize', 8)

	rmpath lib/CategoricalScatterplot
end
