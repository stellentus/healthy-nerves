% columnsWithNaN returns any column with NaN from BOTH datasets
function [indices] = columnsWithNaN(participant, data1, data2)
	% Calculate which columns contain NaN for each type
	cNan = sum(isnan(data1));
	mNan = sum(isnan(data2));

	indices = true(1, length(participant));
	for i = 1:length(participant)
		% If either dataset contains NaN for this index, flag it.
		if cNan(i) > 0 || mNan(i) > 0
			indices(i) = false;
			disp('Deleting participant "' + participant(i) + '" because of ' + cNan(i) + ' CP NaN and ' + mNan(i) + ' median NaN.');
		end
	end
end
