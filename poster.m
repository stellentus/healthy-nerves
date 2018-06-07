% poster prints and displays everything for the poster
function poster(dataType)
	shouldDeleteNaN = true;

	addpath import;

	nameLeg = 'Leg';
	[valuesLeg, participantsLeg, measuresLeg, ~, age, sex] = mefimport(pathFor('leg'), shouldDeleteNaN);
	[~, ~, ~, ~, ageTotal, sexTotal] = mefimport(pathFor('leg'), false);

	nameArm = 'Arm';
	[valuesArm, participantsArm, measuresArm] = mefimport(pathFor('arm'), shouldDeleteNaN);

	% Load SCI data
	[valuesLegSCI, participantsSCI] = mefimport(pathFor('legSCI'), shouldDeleteNaN);

	rmpath import;

	addpath poster;

	correlations(valuesLeg, valuesArm, participantsLeg, participantsArm);

	countParticipants(nameLeg, participantsLeg, measuresLeg);
	countParticipants(nameArm, participantsArm, measuresArm);

	primaryWeights(nameLeg, valuesLeg, measuresLeg);
	primaryWeights(nameArm, valuesArm, measuresArm);

	graphVariance(nameLeg, valuesLeg, nameArm, valuesArm);

	ladderPlot(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm);

	sciClustering(nameLeg, valuesLeg, participantsLeg, valuesLegSCI, participantsSCI, 1);
	sciClustering(nameLeg, valuesLeg, participantsLeg, valuesLegSCI, participantsSCI, 3);

	distancePrint(valuesLeg, participantsLeg, valuesLegSCI, participantsSCI, 5);

	% ageDistribution(age, sex, ageTotal, sexTotal);

	rmpath poster;
end
