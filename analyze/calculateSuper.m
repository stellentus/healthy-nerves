% calculateSuper calculates superexcitability for the given file(s).
function [super1, super2, pVal] = calculateSuper(file1, file2)
	if nargout > 1 && nargin < 2
		error("Two filenames are required when more than 1 output is used.");
	end
	if nargin < 1
		error("An Excel filename must be provided.");
	end

	addpath ./import;

	[~, rcArray1] = mefRCimport(file1);
	super1 = calcSuper(rcArray1);

	if nargin == 1
		fprintf("Superexcitability (%%) is %.3f (%.3f).\n", mean(super1), std(super1));
		rmpath ./import;
		return
	end

	[~, rcArray2] = mefRCimport(file2);
	super2 = calcSuper(rcArray2);

	[~, pVal] = ttest2(super1, super2);

	fprintf("Superexcitability (%%) is %.3f (%.2f) and %.3f (%.2f) with p=%.5f.\n", mean(super1), std(super1), mean(super2), std(super2), pVal);
	rmpath ./import;
end

function super = calcSuper(rcArray)
	% Calculate the moving mean over 3 samples (across columns, not rows).
	rcMean = movmean(rcArray, 3, 1, 'omitnan');

	% Truncate at the last index we care about, since we won't go past 12ms.
	% The QTRAC manual says it stops after 12ms, but that's clearly not what it outputs. Nonetheless, that's what we'll use.
	% QTRAC also just sets the value to zero if none of the masurements go below 0, but that makes it more difficult to
	% compare our results which don't have superexcitability, so that's another reason to do what the manual says rather
	% than what the program does. It makes for a simpler, more comparable measure.
	rcMean = rcMean(1:8, :);

	super = min(rcMean, [], 1);
end
