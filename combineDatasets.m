% combineDatasets combines two datasets, renaming the list of measures
function [measures, values, shortNames] = combineDatasets(measures, values1, name1, values2, name2)
	% Create short names
	shortNames = [];
	startLabel = 'A';
	for i = 1:length(measures)
		if startLabel > 'Z'
			startLabel = 'a';
		end
		shortNames = [shortNames; cellstr(startLabel)];
		startLabel = char(startLabel + 1);
	end
	shortNames = [strcat(name1(1), shortNames) strcat(name2(1), shortNames)];

	measures = [strcat(name1, {' '}, measures) strcat(name2, {' '}, measures)];
	values = [values1, values2];
end
