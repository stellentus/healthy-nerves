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

	measures = canonicalNamesNoTE20();

	% Load the data
	[canValues, canParticipants, canNum, measures] = importCleanMEF(strcat(pathPrefix, 'human/FESmedianAPB_Concatenated.xlsx'), measures, nanMethod);
	[legValues, legParticipants, legNum] = importCleanMEF(strcat(pathPrefix, 'human/CPrepeatedmeasures.xlsx'), measures, nanMethod); % I'm not using the full set because QTRAC chokes on Excel import after around 130 rows
	[japValues, japParticipants, japNum] = importCleanMEF(strcat(pathPrefix, 'Japan'), measures, nanMethod);
	[porValues, porParticipants, porNum] = importCleanMEF(strcat(pathPrefix, 'Portugal'), measures, nanMethod);

	save(savefilepath, 'canValues', 'canParticipants', 'canNum', 'japValues', 'japParticipants', 'japNum', 'porValues', 'porParticipants', 'porNum', 'legValues', 'legParticipants', 'legNum', 'measures', 'nanMethod')
end
