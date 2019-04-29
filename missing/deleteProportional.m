% deleteProportional deletes proportional amounts of missing data
function [missingX, completeX, mask, originalMissingX, missingMask, count] = deleteProportional(X, target)
	nanPercent = countMissing('bin/missing-normative.mat');

	numMissing = 0;
	count = 0;
	while (numMissing == 0) || (nargin == 2 && numMissing ~= target) % At least once, but keep going if not on target
		[missingX, completeX, mask, originalMissingX, missingMask] = delete(X, nanPercent);
		numMissing = size(missingX, 1);
		count = count + 1;
	end
	% Could print the number of iterations here
end

function [missingX, completeX, mask, originalMissingX, missingMask] = delete(X, nanPercent)
	TOTAL_COUNT = size(X, 1);
	mask = ones(size(X));

	for i=1:length(nanPercent)
		if nanPercent(i) == 0
			continue;
		end

		% Get indices of values to delete
		if i == 26
			% Refractoriness at 2.5ms can only be set if 2.0 is also set.
			delRef2 = find(mask(:, 29) == 0);
			delIdx = delRef2(randi(length(delRef2), round(nanPercent(i)*TOTAL_COUNT), 1));
		else
			delIdx = randi(TOTAL_COUNT, round(nanPercent(i)*TOTAL_COUNT), 1);
		end

		% Create mask
		mask(delIdx, i) = 0;
	end

	% Create NaN mask
	maskNaN = mask;
	maskNaN(mask == 0) = NaN;

	missingIndices = find(nanPercent ~= 0);
	completeIndices = setxor(missingIndices, [1:TOTAL_COUNT]);

	Xdel = X .* maskNaN;
	missingX = Xdel(missingIndices, :);
	completeX = X(completeIndices, :);

	originalMissingX = X(missingIndices, :);
	missingMask = mask(missingIndices, :);
end
