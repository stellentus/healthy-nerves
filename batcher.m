%% batcher detects batch effects.
function [canValues, canParticipants, legValues, legParticipants, japValues, japParticipants, porValues, porParticipants, measures] = batcher()
	nanMethod = 'none';

	% Load the data
	addpath import;
	addpath missing;
	[canValues, canParticipants, canMeasures] = mefimport('data/human/MedianRepeatedMeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all median, not just repeated
	canValues = fillWithMethod(canValues, nanMethod, true);
	[legValues, legParticipants, legMeasures] = mefimport('data/human/CPrepeatedmeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all CP, not just repeated
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

	% Flatten Japanese and Porguguese data
	[japValues, japParticipants] = flattenStructs(japValues, japParticipants);
	[porValues, porParticipants] = flattenStructs(porValues, porParticipants);
end

function [flatVals, flatParts] = flattenStructs(structVals, structParts)
	flatVals = [];
	flatParts = [];
	fields = fieldnames(structVals);
	for i = 1:numel(fields)
		flatVals = [flatVals; structVals.(fields{i})];
		flatParts = [flatParts; structParts.(fields{i})];
	end
end
