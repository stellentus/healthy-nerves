% posterCAN2018 creates figures for my CAN Symposium 2018 poster.
function posterCAN2018()
	addpath import;

	% Load data
	[cData, cParticipantNames, cMeasureNames] = mefimport(pathFor('leg'));
	[mData, mParticipantNames, mMeasureNames] = mefimport(pathFor('arm'));

	% Fill missing values
	addpath missing;
	X = [cData; mData];
	X = fillIterate(X, [[]], ~isnan(X), struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
	cData = X(1:length(cParticipantNames), :);
	mData = X(length(cParticipantNames)+1:end, :);
	rmpath missing;
	clear X;

	% Delete measures and participants unique to one dataset
	[cData, mData, participants, measures] = retainMatchingParticipants(cData, cParticipantNames, cMeasureNames, mData, mParticipantNames, mMeasureNames);
	clear cParticipantNames cMeasureNames mParticipantNames mMeasureNames
	clear participants;

	rmpath import;

	addpath analyze;
	corrArmLeg(cData, mData, measures);
	rmpath analyze;

	% TODO: Compare correlations with and without missing data.
	% TODO: Add back the "Large, Medium, Small" correlation labels.
end
