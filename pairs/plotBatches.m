function plotBatches()
	load('bin/missing-normative.mat');
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	filename = sprintf("scatters");
	[~,~] = mkdir('img/pairs'); % Read and ignore returns to suppress warning if dir exists.
	pathstr = sprintf('img/pairs/%s-%d-%d-%d-%d%d%2.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	subplot(2, 3, 1)
	plotPair("Threshold Electrotonus", values, labels, measures, 11, 18);
	subplot(2, 3, 2)
	plotPair("Recovery Cycle", values, labels, measures, 29, 13);
	subplot(2, 3, 3)
	plotPair("Charge Duration", values, labels, measures, 3, 2);
	ylabel("SDTC (ms)");
	subplot(2, 3, 4)
	plotPair("Threshold I/V", values, labels, measures, 6, 25);
	subplot(2, 3, 5)
	plotPair("Stimulus Response", values, labels, measures, 5, 1);
	ylabel("Stim for 50% max");
	subplot(2, 3, 6)
	plotPair("Other", values, labels, measures, 8, 14);
	xlabel("Temperature (C)");

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/pairs/', filename, '.png')); % Also save without timestamp
end
