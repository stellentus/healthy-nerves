function brain(newPath)
	if nargin < 1
		newPath = 'img/brain/';
	end
	[~,~] = mkdir(newPath); % Read and ignore returns to suppress warning if dir exists.

	saveNormative('bin/batch-normative.mat', 'IterateCascadeAuto');

	% Generate table for sex comparison.
	load("bin/batch-normative.mat");
	values = [canValues; japValues; porValues];
	normativeSex(false, values, measures);

	% Create table and figure for regression.
	savePlot(newPath, 'barr2-5', 0.05, values, canValues, japValues, porValues);
	savePlot(newPath, 'barr2-0', 0, values, canValues, japValues, porValues);

	close all;

	addpath batches;
	printStats('bin/batch-normative.mat');
	rmpath batches;
end

function savePlot(newPath, filename, threshold, values, canValues, japValues, porValues)
	pathstr = sprintf('%s/%s-%02d-%02d-%02d-%02d-%02d-%02.0f', newPath, filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	subplot(2, 2, 1);
	normativeMultiRegress(threshold, true, true, values, "Combined Dataset");
	subplot(2, 2, 2);
	normativeMultiRegress(threshold, true, true, canValues, "Canada");
	subplot(2, 2, 3);
	normativeMultiRegress(threshold, true, true, japValues, "Japan");
	subplot(2, 2, 4);
	normativeMultiRegress(threshold, true, true, porValues, "Portugal");

	suptitle("Contribution of Age, Temperature, and Sex to Variance in Excitability Variables");

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat(newPath, filename, '.png')); % Also save without timestamp
end
