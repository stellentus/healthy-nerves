% missmiss loads missing data and does stuff with it
function [X_missing, X_full, X, mask] = missmiss()
	% Load data
	addpath import;
	armValues = mefimport(pathFor('arm'), true);
	legValues = mefimport(pathFor('leg'), true);
	rmpath import;

	% Store all samples as X
	X = [armValues; legValues];
	clear armValues legValues;

	addpath missing
	numMissing = 0;
	count = 0;
	while numMissing ~= 25
		[X_missing, X_full, mask] = deleteProportional(X);
		numMissing = size(X_missing, 1);
		count = count + 1;
	end
	fprintf('The process took %d iterations.\n', count)
	rmpath missing
end
