% deleteNaN deletes all NaN rows
function [values, participants, measures] = deleteNaN(participants, measures, data1, data2, uniqueMeasures)
	if nargin == 3
		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(participants, data1);
		data1 = data1(indices, :);
		participants = participants(indices);
		clear indices;

		values = data1;
	else
		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(participants, data1) & rowsWithNaN(participants, data2);
		participants = participants(indices);
		data1Matched = data1(indices, :);
		data2Matched = data2(indices, :);

		% Print all measures correlated between the datasets.
		correlations(measures, data1Matched, data2Matched);

		% Combine the arm and leg data into one dataset
		[values, measures] = combineDatasets(measures, data1Matched, 'Leg', data2Matched, 'Arm', uniqueMeasures);
	end
end
