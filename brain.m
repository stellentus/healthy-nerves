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
	normativeMultiRegress(true, true, values, "in All Three Countries", '-all');
	normativeMultiRegress(true, true, canValues, "in Canada", '-can');
	normativeMultiRegress(true, true, japValues, "in Japan", '-jap');
	normativeMultiRegress(true, true, porValues, "in Portugal", '-por');
	copyfile('img/stats/barr2-5-all.png', strcat(newPath, 'barr2-5-all.png'));
	copyfile('img/stats/barr2-0-all.png', strcat(newPath, 'barr2-0-all.png'));
	copyfile('img/stats/barr2-5-can.png', strcat(newPath, 'barr2-5-can.png'));
	copyfile('img/stats/barr2-0-can.png', strcat(newPath, 'barr2-0-can.png'));
	copyfile('img/stats/barr2-5-jap.png', strcat(newPath, 'barr2-5-jap.png'));
	copyfile('img/stats/barr2-0-jap.png', strcat(newPath, 'barr2-0-jap.png'));
	copyfile('img/stats/barr2-5-por.png', strcat(newPath, 'barr2-5-por.png'));
	copyfile('img/stats/barr2-0-por.png', strcat(newPath, 'barr2-0-por.png'));

	close all;

	addpath batches;
	printStats('bin/batch-normative.mat');
	rmpath batches;
end
