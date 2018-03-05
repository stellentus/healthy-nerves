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
	[X_missing, X_full, mask] = deleteProportional(X, 25);
	rmpath missing
end
