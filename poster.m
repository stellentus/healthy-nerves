% poster prints and displays everything for the poster
function poster(dataType)
	shouldDeleteNaN = true;

	addpath import;

	nameLeg = 'Leg';
	[valuesLeg, participantsLeg, measuresLeg] = loadData('leg', shouldDeleteNaN);

	nameArm = 'Arm';
	[valuesArm, participantsArm, measuresArm] = loadData('arm', shouldDeleteNaN);

	% Load SCI data
	[valuesLegSCI, participantsSCI] = loadData('legSCI', shouldDeleteNaN);

	% Return values aren't used; calling loadData('all') prints correlations.
	loadData('all', shouldDeleteNaN);

	rmpath import;

	addpath poster;

	correlations(measuresLeg, valuesLeg, valuesArm, participantsLeg, participantsArm);

	count(nameLeg, participantsLeg, measuresLeg);
	count(nameArm, participantsArm, measuresArm);

	primaryWeights(nameLeg, valuesLeg, measuresLeg);
	primaryWeights(nameArm, valuesArm, measuresArm);

	graphVariance(nameLeg, valuesLeg, nameArm, valuesArm);

	ladderPlot(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm);

	sciClustering(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm, valuesLegSCI, participantsSCI, 1);
	sciClustering(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm, valuesLegSCI, participantsSCI, 30);

	rmpath poster;
end
