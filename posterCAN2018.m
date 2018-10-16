% posterCAN2018 creates figures for my CAN Symposium 2018 poster.
function posterCAN2018()
	addpath import;

	% Load data
	[cData, cParticipantNames, cMeasureNames] = mefimport(pathFor('leg'));
	[mData, mParticipantNames, mMeasureNames] = mefimport(pathFor('arm'));


	% Delete measures and participants unique to one dataset
	[cData, mData, participants, measures] = retainMatchingParticipants(cData, cParticipantNames, cMeasureNames, mData, mParticipantNames, mMeasureNames);
	clear cParticipantNames cMeasureNames mParticipantNames mMeasureNames;

	% Delete NaN rows (i.e. participants with missing values)
	[participants, cData, mData] = deleteNaN(participants, cData, mData);
	clear participants;

	rmpath import;

	addpath analyze;
	corrArmLeg(cData, mData, measures);
	rmpath analyze;
end
