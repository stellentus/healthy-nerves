% missmiss loads missing data and does stuff with it
function [missingX, completeX, mask, sortedAllX, sortedMask] = missmiss()
	% Load data
	addpath import;
	armValues = mefimport(pathFor('arm'), true);
	legValues = mefimport(pathFor('leg'), true);
	rmpath import;

	% Store all samples as X
	X = [armValues; legValues];
	clear armValues legValues;

	addpath missing
	[missingX, completeX, mask, sortedAllX, sortedMask] = deleteProportional(X, 25);
	rmpath missing
end
