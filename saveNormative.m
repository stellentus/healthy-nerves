% saveNormative loads multiple datasets and confirms they can be concatenated.
function saveNormative(savefilepath, nanMethod)
	if nargin < 2
		nanMethod = 'IterateRegr';
		if nargin < 1
			savefilepath = 'bin/batch-normative.mat';
		end
	end

	addpath import;

	measures = canonicalNamesNoTE20();

	% Load the data
	[canValues, canParticipants, canNum, measures] = importCleanMEF('data/human/FESmedianAPB_Concatenated.xlsx', measures, nanMethod);
	[legValues, legParticipants, legNum] = importCleanMEF('data/human/CPrepeatedmeasures.xlsx', measures, nanMethod); % I'm not using the full set because QTRAC chokes on Excel import after around 130 rows
	[japValues, japParticipants, japNum] = importCleanMEF('data/Japan', measures, nanMethod);
	[porValues, porParticipants, porNum] = importCleanMEF('data/Portugal', measures, nanMethod);

	save(savefilepath, 'canValues', 'canParticipants', 'canNum', 'japValues', 'japParticipants', 'japNum', 'porValues', 'porParticipants', 'porNum', 'legValues', 'legParticipants', 'legNum', 'measures', 'nanMethod')
end
