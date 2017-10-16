% poster prints and displays everything for the poster
function poster(dataType)
	shouldDeleteNaN = true;

	addpath import;

	nameLeg = 'Leg';
	[valuesLeg, participantsLeg, measuresLeg] = loadData('leg', shouldDeleteNaN);

	nameArm = 'Arm';
	[valuesArm, participantsArm, measuresArm] = loadData('arm', shouldDeleteNaN);

	% Load SCI data
	valuesLegSCI = loadData('legSCI', shouldDeleteNaN);

	% Return values aren't used; calling loadData('all') prints correlations.
	loadData('all', shouldDeleteNaN);

	rmpath import;

	addpath poster;

	count(nameLeg, participantsLeg, measuresLeg);
	count(nameArm, participantsArm, measuresArm);
	primaryWeights(nameLeg, valuesLeg, measuresLeg);
	primaryWeights(nameArm, valuesArm, measuresArm);
	graphVariance(nameLeg, valuesLeg, nameArm, valuesArm);
	ladderPlot(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm);
	sciClustering(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm, valuesLegSCI, 1);
	sciClustering(nameLeg, valuesLeg, participantsLeg, nameArm, valuesArm, participantsArm, valuesLegSCI, 24);

	rmpath poster;
end
