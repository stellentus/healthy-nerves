% combineDatasets combines two datasets, renaming the list of measures
function [values, measures, shortNames] = combineDatasets(measures, values1, name1, values2, name2, uniqueMeasures)
	% Create short names
	shortNames = shortenNames(measures);
	shortNames = [strcat(name1(1), shortNames) strcat(name2(1), shortNames(uniqueMeasures))];

	measures = [strcat(name1, {' '}, measures) strcat(name2, {' '}, measures(uniqueMeasures))];
	values = [values1, values2(:,uniqueMeasures)];
end
