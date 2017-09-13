% handleMissingData deletes any column with NaN from BOTH datasets
function [cData, cParticipant, mData, mParticipant] = handleMissingData(cData, cParticipant, mData, mParticipant)
	% Calculate which columns contain NaN for each type
	cNan = sum(isnan(cData));
	mNan = sum(isnan(mData));

	index = true(1, length(cParticipant));
	for i = 1:length(cParticipant)
		% If either dataset contains NaN for this index, flag it.
		if cNan(i) > 0 || mNan(i) > 0
			index(i) = false;
			disp('Deleting participant "' + cParticipant(i) + '" because of ' + cNan(i) + ' CP NaN and ' + mNan(i) + ' median NaN.');
		end
	end

	% Delete the flagged indices.
	cData = cData(:, index);
	cParticipant = cParticipant(index);
	mData = mData(:, index);
	mParticipant = mParticipant(index);
end
