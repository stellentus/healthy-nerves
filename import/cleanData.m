function [values, participants, num] = cleanData(values, participants, nanMethod, measures)
	[values, participants] = deleteNoSex(values, participants);
	[values, participants] = deduplicate(values, participants);
	[values] = removeWildRefractoriness(values, measures);
	[values, participants] = removeExcessivelyMissing(values, participants);
	if nargin >= 3
		addpath ./missing;
		values = fillWithMethod(values, nanMethod, true);
		rmpath ./missing;
	end
	num = size(values, 1);
end

function [vals, parts] = deleteNoSex(vals, parts)
	hasSex = ismember(vals(:, 15), [2.0 1.0]);
	if sum(~hasSex) > 0
		fprintf('Deleting sexless %s.\n', parts(~hasSex));
	end
	vals = vals(hasSex, :);
	parts = parts(hasSex);
end

function [dedupVals, dedupParts] = deduplicate(vals, parts)
	orig = length(parts);
	[~, indices] = unique(parts, 'first');
	dedupParts = parts(sort(indices));
	dedupVals = vals(sort(indices), :);
	if length(dedupParts) ~= orig
		fprintf('Deleted %d duplicates\n', orig-length(dedupParts));
	end
end

function [vals] = removeWildRefractoriness(vals, measures)
	% If Refractoriness is too large, it's being imputed by QTRAC, and QTRAC does a bad job sometimes.
	ref25 = find(strcmp(measures, "Refractoriness at 2.5ms (%)"));
	ref2 = find(strcmp(measures, "Refractoriness at 2 ms (%)"));
	vals(vals(:, ref2)>200, ref2) = nan;
	vals(vals(:, ref25)>100, ref25) = nan;
end

% removeExcessivelyMissing removes rows with more than 10 missing values
function [vals, parts] = removeExcessivelyMissing(vals, parts, maxMissing)
	if nargin < 3
		maxMissing = 10;
	end

	numMissing = sum(isnan(vals), 2);
	excessiveMissing = numMissing>maxMissing;
	if sum(excessiveMissing) > 0
		fprintf('Deleting excessively missing %s.\n', parts(excessiveMissing));
	end
	vals = vals(~excessiveMissing, :);
	parts = parts(~excessiveMissing);
end
