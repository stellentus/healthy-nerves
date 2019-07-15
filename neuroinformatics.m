function neuroinformatics(newPath)
	if nargin < 1
		newPath = 'img/neuroinformatics/';
	end
	mkdir(newPath);

	saveNormative();
	saveNonNormative();

	missmiss('standard', 'parallelize', true, 'iters', 99, 'fixedSeed', false, 'numToUse', 0);
	copyfile('img/missmiss/244-standard-value.png', strcat(newPath, 'missmiss-244-standard-value.png'));
	copyfile('img/missmiss/244-standard-times.png', strcat(newPath, 'missmiss-244-standard-times.png'));

	missmiss('standard', 'parallelize', true, 'iters', 99, 'fixedSeed', false, 'numToUse', 40);
	copyfile('img/missmiss/40-standard-value.png', strcat(newPath, 'missmiss-40-standard-value.png'));

	batcherFigures();
	copyfile('img/batch/norm-rand.png', strcat(newPath, 'batch-norm-rand.png'));
	copyfile('img/batch/country-splits.png', strcat(newPath, 'batch-country-splits.png'));
	copyfile('img/batch/vs-nonnorm.png', strcat(newPath, 'batch-vs-nonnorm.png'));
	copyfile('img/batch/two-countries.png', strcat(newPath, 'batch-two-countries.png'));

	batchDemos();
	copyfile('img/batch/vi-comparison.png', strcat(newPath, 'vi-comparison.png'));
end
