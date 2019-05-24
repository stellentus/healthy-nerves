% saveNormative loads multiple datasets and confirms they can be concatenated.
function saveNormative(savefilepath, pathPrefix, nanMethod)
	if nargin < 3
		nanMethod = 'IterateRegr';
		if nargin < 2
			pathPrefix = 'data/';
			if nargin < 1
				savefilepath = 'bin/batch-normative.mat';
			end
		end
	end

	addpath import;

	% Load the data
	[canValues, canParticipants, canMeasures] = mefimport(strcat(pathPrefix, 'human/FESmedianAPB_Concatenated.xlsx'), false, false, canonicalNamesNoTE20());
	[legValues, legParticipants, legMeasures] = mefimport(strcat(pathPrefix, 'human/CPrepeatedmeasures.xlsx'), false, false, canonicalNamesNoTE20()); % I'm not using the full set because QTRAC chokes on Excel import after around 130 rows
	[japValues, japParticipants, japMeasures] = importAllXLSX('none', strcat(pathPrefix, 'Japan'));
	[porValues, porParticipants, porMeasures] = importAllXLSX('none', strcat(pathPrefix, 'Portugal'));

	% Ensure all datasets have the desired measures
	assert(isequal(canMeasures, legMeasures), 'Canadian arm and leg measures are not the same');
	assert(isequal(canMeasures, japMeasures), 'Canadian and Japanese measures are not the same');
	assert(isequal(canMeasures, porMeasures), 'Canadian and Portuguese measures are not the same');
	measures = canMeasures;

	% Flatten Japanese and Portuguese data
	[japValues, japParticipants] = flattenStructs(japValues, japParticipants);
	[porValues, porParticipants] = flattenStructs(porValues, porParticipants);

	% Delete people who have no sex
	[canValues, canParticipants] = deleteNoSex(canValues, canParticipants);
	[legValues, legParticipants] = deleteNoSex(legValues, legParticipants);
	[japValues, japParticipants] = deleteNoSex(japValues, japParticipants);
	[porValues, porParticipants] = deleteNoSex(porValues, porParticipants);

	% Delete duplicate records
	[canValues, canParticipants] = deduplicate(canValues, canParticipants);
	[legValues, legParticipants] = deduplicate(legValues, legParticipants);
	[japValues, japParticipants] = deduplicate(japValues, japParticipants);
	[porValues, porParticipants] = deduplicate(porValues, porParticipants);

	rmpath import;

	% Fill missing data
	addpath missing;
	canValues = fillWithMethod(canValues, nanMethod, true);
	legValues = fillWithMethod(legValues, nanMethod, true);
	japValues = fillWithMethod(japValues, nanMethod, true);
	porValues = fillWithMethod(porValues, nanMethod, true);
	rmpath missing;

	canNum = size(canValues, 1);
	japNum = size(japValues, 1);
	porNum = size(porValues, 1);
	legNum = size(legValues, 1);

	save(savefilepath, 'canValues', 'canParticipants', 'canNum', 'japValues', 'japParticipants', 'japNum', 'porValues', 'porParticipants', 'porNum', 'legValues', 'legParticipants', 'legNum', 'measures', 'nanMethod')
end
