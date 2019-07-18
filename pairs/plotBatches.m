function plotBatches()
	load('bin/batch-normative.mat');
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	subplot(2, 2, 1)
	plotPair("Threshold Electrotonus", values, labels, measures, 10, 18);
	subplot(2, 2, 2)
	plotPair("Recovery Cycle", values, labels, measures, 12, 13);
	subplot(2, 2, 3)
	plotPair("Charge Duration", values, labels, measures, 3, 2);
	ylabel("SDTC (ms)");
	subplot(2, 2, 4)
	plotPair("Threshold I/V", values, labels, measures, 6, 25);

	addpath lib;
	savePlot(fig, false, 'img/pairs', 'scatters');
	rmpath lib;
end
