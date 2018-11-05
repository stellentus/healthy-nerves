%% batcher detects batch effects.
function [canValues, canParticipants, canMeasures, legValues, legParticipants, legMeasures, japValues, japParticipants, japMeasures, porValues, porParticipants, porMeasures] = batcher()
	nanMethod = 'none';

	% Load the data
	addpath import;
	addpath missing;
	[canValues, canParticipants, canMeasures] = mefimport('data/human/MedianRepeatedMeasures.xlsx', false, false, canonicalNamesNoTE20());
	canValues = fillWithMethod(canValues, nanMethod, true);
	[legValues, legParticipants, legMeasures] = mefimport('data/human/CPrepeatedmeasures.xlsx', false, false, canonicalNamesNoTE20());
	legValues = fillWithMethod(legValues, nanMethod, true);
	rmpath missing;

	[japValues, japParticipants, japMeasures] = importAllXLSX(nanMethod, 'data/Japan');
	[porValues, porParticipants, porMeasures] = importAllXLSX(nanMethod, 'data/Portugal');
	rmpath import;
end
