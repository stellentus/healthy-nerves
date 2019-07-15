function neuroinformatics(newPath)
	if nargin < 1
		newPath = 'img/neuroinformatics/';
	end
	mkdir(newPath);

	saveNormative('bin/batch-normative.mat', 'IterateCascadeAuto');
	saveNormative('bin/missing-normative.mat', 'none');
	saveNonNormative('bin/non-normative.mat', 'IterateCascadeAuto');

	addpath batches;
	printStats('bin/batch-normative.mat');
	rmpath batches;

	missmiss('standard', 'parallelize', true, 'iters', 30, 'fixedSeed', false, 'numToUse', 0, 'file', "bin/missing-normative.mat");
	copyfile('img/missmiss/244-standard-value.png', strcat(newPath, 'missmiss-244-standard-value.png'));
	copyfile('img/missmiss/244-standard-times.png', strcat(newPath, 'missmiss-244-standard-times.png'));

	missmiss('standard', 'parallelize', true, 'iters', 30, 'fixedSeed', false, 'numToUse', 40, 'file', "bin/missing-normative.mat");
	copyfile('img/missmiss/40-standard-value.png', strcat(newPath, 'missmiss-40-standard-value.png'));

	batcherFigures('normfile', "bin/batch-normative.mat", 'nonnormfile', "bin/non-normative.mat");
	copyfile('img/batch/norm-rand.png', strcat(newPath, 'batch-norm-rand.png'));
	copyfile('img/batch/country-splits.png', strcat(newPath, 'batch-country-splits.png'));
	copyfile('img/batch/vs-nonnorm.png', strcat(newPath, 'batch-vs-nonnorm.png'));
	copyfile('img/batch/two-countries.png', strcat(newPath, 'batch-two-countries.png'));

	batchDemos();
	copyfile('img/batch/vi-comparison.png', strcat(newPath, 'vi-comparison.png'));

	close all;
end
