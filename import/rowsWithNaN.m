% rowsWithNaN returns any row with NaN.
function [indices] = rowsWithNaN(participant, data1)
	indices = sum(isnan(data1), 2) > 0;
end
