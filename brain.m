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
	normativeMultiRegress(true, values);
	copyfile('img/stats/barr2-5.png', strcat(newPath, 'barr2-5.png'));
	copyfile('img/stats/barr2-0.png', strcat(newPath, 'barr2-0.png'));

	close all;

	addpath batches;
	printStats('bin/batch-normative.mat');
	rmpath batches;
end
