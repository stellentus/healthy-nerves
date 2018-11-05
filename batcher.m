%% batcher detects batch effects.
function [canValues, canParticipants, legValues, legParticipants, japValues, japParticipants, porValues, porParticipants, measures] = batcher()
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

	% Ensure all datasets have the desired measures
	assert(isequal(canMeasures, legMeasures), 'Canadian arm and leg measures are not the same');
	assert(isequal(canMeasures, japMeasures), 'Canadian and Japanese measures are not the same');
	assert(isequal(canMeasures, porMeasures), 'Canadian and Portuguese measures are not the same');
	measures = canMeasures;
	clear legMeasures japMeasures porMeasures;
end
