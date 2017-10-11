% deleteNaN deletes all NaN rows
function [values, participants, measures] = deleteNaN(participants, measures, data1, data2, uniqueMeasures)
	if nargin == 3
		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(participants, data1);
		[participants, data1] = deleteRows(indices, participants, data1);
		clear indices;

		values = data1;
	else
		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(participants, data1, data2);
		[participants, data1Matched, data2Matched] = deleteRows(indices, participants, data1, data2);

		% Combine the arm and leg data into one dataset
		[values, measures] = combineDatasets(measures, data1Matched, 'Leg', data2Matched, 'Arm', uniqueMeasures);
	end
end

function [participants, data1, data2] = deleteRows(indices, participants, data1, data2)
	data1 = data1(indices, :);
	if nargin == 4
		data2 = data2(indices, :);
	else
		data2 = [];
	end
	participants = participants(indices);
end