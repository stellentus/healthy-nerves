% rowsWithNaN returns any row with NaN.
function [indices] = rowsWithNaN(participant, data1)
	% Calculate which rows contain NaN for each type
	indices = sum(isnan(data1), 2) == 0;
end
