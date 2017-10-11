% combineDatasets combines two datasets, renaming the list of measures
function [values, measures] = combineDatasets(measures, values1, name1, values2, name2, uniqueMeasures)
	measures = [strcat(name1, {' '}, measures) strcat(name2, {' '}, measures(uniqueMeasures))];
	values = [values1, values2(:,uniqueMeasures)];
end
