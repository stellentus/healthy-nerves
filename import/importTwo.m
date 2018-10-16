% importTwo imports two files and retains only matching rows and columns
function [cData, mData, participants, measures] = importTwo(cPath, mPath)
	% Import the data from MEF
	[cData, cParticipantNames, cMeasureNames] = mefimport(cPath);
	[mData, mParticipantNames, mMeasureNames] = mefimport(mPath);

	[cData, mData, participants, measures] = retainMatchingParticipants(cData, cParticipantNames, cMeasureNames, mData, mParticipantNames, mMeasureNames);
end
