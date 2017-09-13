% analyze runs an analysis on the data
function analyze()
	% Import the data from MEF
	[cData, cMeasureNames, cParticipantNames, cStats] = mefimport('data/CPrepeatedmeasures.xlsx');
	[mData, mMeasureNames, mParticipantNames, mStats] = mefimport('data/MedianRepeatedmeasures.xlsx');

	% Print warnings if something is odd
	stats(mData, mStats, mMeasureNames);
	stats(cData, cStats, cMeasureNames);

	% Handle missing data
	[cData, cParticipantNames, mData, mParticipantNames] = handleMissingData(cData, cParticipantNames, mData, mParticipantNames);
end
