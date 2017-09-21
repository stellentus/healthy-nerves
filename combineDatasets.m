% combineDatasets combines two datasets, renaming the list of measures
function [measures, values] = combineDatasets(measures, values1, name1, values2, name2)
	measures = [strcat(name1, {' '}, measures) strcat(name2, {' '}, measures)];
	values = [values1, values2];
end
