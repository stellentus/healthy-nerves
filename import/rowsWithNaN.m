% rowsWithNaN returns any row with NaN.
function [indices] = rowsWithNaN(participant, data1)
	% Calculate which rows contain NaN for each type
	cNan = sum(isnan(data1), 2);

	indices = true(1, length(participant));
	deletions = [];
	for i = 1:length(participant)
		% If the dataset contains NaN for this index, flag it.
		if cNan(i) > 0
			indices(i) = false;
			deletions = [deletions; participant(i)];
		end
	end
end
