% rowsWithNaN returns any row with NaN from BOTH datasets.
% If only one dataset is provided, then only it is used.
function [indices] = rowsWithNaN(participant, data1, data2)
	% Calculate which rows contain NaN for each type
	cNan = sum(isnan(data1), 2);
	if nargin == 3
		mNan = sum(isnan(data2), 2);
	else
		mNan = cNan; % If only one dataset was provided, just reuse the same matrix.
	end

	indices = true(1, length(participant));
	deletions = [];
	for i = 1:length(participant)
		% If either dataset contains NaN for this index, flag it.
		if cNan(i) > 0 || mNan(i) > 0
			indices(i) = false;
			deletions = [deletions; participant(i)];
		end
	end

	if ~isempty(deletions)
		disp('Deleting participants "' + strjoin(deletions, ', ') + '" because one of the data points is missing.');
	end
end
