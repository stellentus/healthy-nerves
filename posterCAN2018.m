% posterCAN2018 creates figures for my CAN Symposium 2018 poster.
function posterCAN2018()
	addpath import;
	[cData, mData, participants, measures] = importTwo(pathFor('leg'), pathFor('arm'));
	[participants, cData, mData] = deleteNaN(participants, cData, mData);
	rmpath import;

	addpath analyze;
	corrArmLeg(cData, mData, measures);
	rmpath analyze;
end
