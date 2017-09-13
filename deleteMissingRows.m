% deleteMissingRows deletes any column with NaN from BOTH datasets
function [data1, data2, participant] = deleteMissingRows(data1, data2, participant)
	% Calculate which columns contain NaN for each type
	cNan = sum(isnan(data1));
	mNan = sum(isnan(data2));

	index = true(1, length(participant));
	for i = 1:length(participant)
		% If either dataset contains NaN for this index, flag it.
		if cNan(i) > 0 || mNan(i) > 0
			index(i) = false;
			disp('Deleting participant "' + participant(i) + '" because of ' + cNan(i) + ' CP NaN and ' + mNan(i) + ' median NaN.');
		end
	end

	% Delete the flagged indices.
	data1 = data1(:, index);
	data2 = data2(:, index);
	participant = participant(index);
end
