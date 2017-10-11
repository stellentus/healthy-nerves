% poster prints and displays everything for the poster
function poster(dataType)
	deleteNaN = true;

	addpath import;

	name1 = 'Arm';
	[values1, participants1, measures1] = loadData('arm', deleteNaN);

	name2 = 'Leg';
	[values2, participants2, measures2] = loadData('leg', deleteNaN);

	% These variables aren't used; calling loadData('all') prints correlations.
	name3 = 'All';
	[values3, participants3, measures3] = loadData('all', deleteNaN);

	rmpath import;

	addpath poster;

	count(name1, participants1, measures1);
	count(name2, participants2, measures2);
	graphVariance(name1, values1, name2, values2);

	rmpath poster;
end
