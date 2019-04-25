% deleteNaN deletes all NaN rows
function [participants, data1Reduced, data2Reduced, indices] = deleteNaN(participants, data1, data2)
	if nargin == 2  % data2 is not included (i.e. it's not both legs and arms for the same participants)
		data2Reduced = [];

		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(data1);
		data1Reduced = data1(indices, :);
		participants = participants(indices);
	else
		% Handle missing data by deleting NaN rows
		indices = rowsWithNaN(data1) & rowsWithNaN(data2);
		participants = participants(indices);
		data1Reduced = data1(indices, :);
		data2Reduced = data2(indices, :);
	end
end

% rowsWithNaN returns any row with NaN.
function [indices] = rowsWithNaN(data1)
	% Calculate which rows contain NaN for each type
	indices = sum(isnan(data1), 2) == 0;
end
