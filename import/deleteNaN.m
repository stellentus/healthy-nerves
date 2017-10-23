% deleteNaN deletes all NaN rows
function [participants, data1Reduced, data2Reduced, indices] = deleteNaN(participants, data1, data2)
	if nargin == 2
		data2Reduced = [];

		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(participants, data1);
		data1Reduced = data1(indices, :);
		participants = participants(indices);
	else
		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(participants, data1) & rowsWithNaN(participants, data2);
		participants = participants(indices);
		data1Reduced = data1(indices, :);
		data2Reduced = data2(indices, :);
	end
end

% rowsWithNaN returns any row with NaN.
function [indices] = rowsWithNaN(participant, data1)
	% Calculate which rows contain NaN for each type
	indices = sum(isnan(data1), 2) == 0;
end
