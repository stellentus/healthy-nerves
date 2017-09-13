% columnsWithNaN returns any column with NaN from BOTH datasets.
% If only one dataset is provided, then only it is used.
function [indices] = columnsWithNaN(participant, data1, data2)
	% Calculate which columns contain NaN for each type
	cNan = sum(isnan(data1));
	if nargin == 3
		mNan = sum(isnan(data2));
	else
		mNan = cNan; % If only one dataset was provided, just reuse the same matrix.
	end

	indices = true(1, length(participant));
	for i = 1:length(participant)
		% If either dataset contains NaN for this index, flag it.
		if cNan(i) > 0 || mNan(i) > 0
			indices(i) = false;
			disp('Deleting participant "' + participant(i) + '" because one of the data points is missing.');
		end
	end
end
