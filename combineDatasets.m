% combineDatasets combines two datasets, renaming the list of measures
function [measures, values, shortNames] = combineDatasets(measures, values1, name1, values2, name2, uniqueMeasures)
	% Create short names
	shortNames = [];
	startLabel = 'a';
	for i = 1:length(measures)
		if startLabel > 'z'
			startLabel = 'A';
		end
		shortNames = [shortNames; cellstr(startLabel)];
		startLabel = char(startLabel + 1);
	end
	shortNames = shortNames';
	shortNames = [strcat(name1(1), shortNames) strcat(name2(1), shortNames(uniqueMeasures))];

	measures = [strcat(name1, {' '}, measures) strcat(name2, {' '}, measures(uniqueMeasures))];
	values = [values1, values2(:,uniqueMeasures)];
end
