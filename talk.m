% talk prints and displays everything for the talk
function talk(dataType)
	shouldDeleteNaN = true;

	addpath import;

	nameLeg = 'Leg';
	[valuesLeg, participantsLeg, measuresLeg, ~, age, sex] = mefimport(pathFor('leg'), shouldDeleteNaN);
	[~, ~, ~, ~, ageTotal, sexTotal] = mefimport(pathFor('leg'), false);

	% Load SCI data
	[valuesLegSCI, participantsSCI] = mefimport(pathFor('legSCI'), shouldDeleteNaN);

	rmpath import;

	addpath poster;

	sciClustering(nameLeg, valuesLeg, participantsLeg, valuesLegSCI, participantsSCI, 1, 20);

	rmpath poster;
end
