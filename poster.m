% poster prints and displays everything for the poster
function poster(dataType)
	addpath poster;
	addpath import;

	count();
	graphVariance();

	rmpath import;
	rmpath poster;
end
