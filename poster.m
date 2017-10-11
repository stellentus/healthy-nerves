% poster prints and displays everything for the poster
function poster(dataType)
	deleteNaN = true;

	addpath import;

	name1 = 'Leg';
	[values1, participants1, measures1] = loadData('leg', deleteNaN);

	name2 = 'Arm';
	[values2, participants2, measures2] = loadData('arm', deleteNaN);

	% These variables aren't used; calling loadData('all') prints correlations.
	name3 = 'All';
	[values3, participants3, measures3] = loadData('all', deleteNaN);

	rmpath import;

	addpath poster;

	count(name1, participants1, measures1);
	count(name2, participants2, measures2);
	primaryWeights(name1, values1, measures1);
	primaryWeights(name2, values2, measures2);
	graphVariance(name1, values1, name2, values2);
	ladderPlot(name1, values1, participants1, name2, values2, participants2);

	rmpath poster;
end
