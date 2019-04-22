% batchDemos creates some demo plots for BVI.
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

	padLen = 4;
	printHeader(padLen);

	addpath batches;
	plotWithRange(1, data1, data2, 500, 0, 0, 500, 30, "A");
	plotWithRange(2, data1, data2, 400, 0, 100, 500, 30, "B");
	plotWithRange(3, data1, data2, 50, 450, 0, 500, 30, "C");
	plotWithRange(4, data1, data2, 0, 500, 0, 500, 30, "D");
	plotWithRange(5, data1, data3, 500, 0, 0, 500, 30, "E");
	plotWithRange(6, data1, data3, 63, 0, 63, 126, 30, "F");
	% plotWithRange(0, data1, data3, 250, 0, 250, 500, 300, "G");
	rmpath batches;
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

	if plotId ~= 0
		subplot(3, 4, plotId*2-1);
		hold on;
		plot(d1(:,1), d1(:,2), '+');
		plot(d2(:,1), d2(:,2), 'x');
		title(letterLabel);
		subplot(3, 4, plotId*2);
		plotBA(ba, letterLabel);
	end
end

% plotBA is used to print a table and plot an array of BatchAnalyzer
function plotBA(ba, figtitle)
	scores = [ba.Score'/ba.BaselineScore_mean ba.BaselineScore'/ba.BaselineScore_mean];
	plotBoxes(figtitle, scores, 'Homogeneity (%)', ["norm(BVI)", "norm(E[BVI_{max}])"]);

	yl = ylim;
	if yl(1) > 0
		yl(1) = 0;
	end
	if yl(2) < 1
		yl(2) = 1;
	end
	ylim(yl)

    textLabel = sprintf("%2.0f%% Homogeneity\np=%s", ba.Homogeneity_mean*100, PString(ba));
	x = 1.5;
	y = 0.3;
	if ba.Homogeneity_mean > 0.85
		y = 0.6;
	end
    text(x, y, textLabel, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap');
end

function printHeader(padLen)
	% Print the table header
	fprintf('%s , Score  ,  std  , Base   ,  std  , Homog ,  PVal  \n', pad("Name", padLen));
	fprintf('%s , ------ , ----- , ------ , ----- , ----- , ------ \n', strrep(pad(" ", padLen), " ", "-"));
end

function plotBoxes(titleLabel, scores, scoreName, testNames)
	addpath lib/CategoricalScatterplot

	CategoricalScatterplot(scores, testNames, 'MarkerSize', 50, 'BoxAlpha', .29, 'LadderLines', true);
	title(titleLabel);
	ylabel(scoreName);

	rmpath lib/CategoricalScatterplot
end
