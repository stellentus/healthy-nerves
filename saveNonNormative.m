% saveNonNormative loads multiple datasets and saves them as a Matlab file.
function saveNonNormative(nanMethod, savefilepath)
	if nargin < 2
		savefilepath = 'bin/non-normative.mat';
		if nargin < 1
			nanMethod = 'Mean';
		end
	end

	% Load the data
	addpath import;
	[sciValues, sciParticipants, sciMeasures] = importAllXLSX('none', 'data/MEM/SCI/Cross Sectional Data/MEM+MEF data');
	[ratTASPValues, ratTASPParticipants, ratTASPMeasures] = mefimport('data/rat/RTA all SP.xlsx', false, false, canonicalNamesNoTE20());
	[ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures] = mefimport('data/rat/TA-KXpair.xlsx', false, false, canonicalNamesNoTE20());
	[ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures] = mefimport('data/rat/RSOL all SP.xlsx', false, false, canonicalNamesNoTE20());
	[ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures] = mefimport('data/rat/SOL-KXpair.xlsx', false, false, canonicalNamesNoTE20());
	rmpath import;

	% Combine pairs of rat data
	[ratTAValues, ratTAParticipants, ratTAMeasures] = combine(ratTASPValues, ratTASPParticipants, ratTASPMeasures, ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures);
	[ratSLValues, ratSLParticipants, ratSLMeasures] = combine(ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures, ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures);
	[ratSPValues, ratSPParticipants, ratSPMeasures] = combine(ratTASPValues, ratTASPParticipants, ratTASPMeasures, ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures);
	[ratKXValues, ratKXParticipants, ratKXMeasures] = combine(ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures, ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures);
	[ratValues, ratParticipants, ratMeasures] = combine(ratSPValues, ratSPParticipants, ratSPMeasures, ratSPValues, ratSPParticipants, ratSPMeasures);
	clear ratTASPValues ratTASPParticipants ratTASPMeasures ratTAKXValues ratTAKXParticipants ratTAKXMeasures;

	% Ensure all datasets have the desired measures
	assert(isequal(sciMeasures, ratTAMeasures), 'SCI and rat TA measures are not the same');
	assert(isequal(sciMeasures, ratSLMeasures), 'SCI and rat SL measures are not the same');
	assert(isequal(sciMeasures, ratSPMeasures), 'SCI and rat SP measures are not the same');
	assert(isequal(sciMeasures, ratKXMeasures), 'SCI and rat KX measures are not the same');
	assert(isequal(sciMeasures, ratMeasures), 'SCI and rat all measures are not the same');
	measures = sciMeasures;

	% Flatten SCI data
	[sciValues, sciParticipants] = flattenStructs(sciValues, sciParticipants);

	% Delete people who have no sex
	[sciValues, sciParticipants] = deleteNoSex(sciValues, sciParticipants);
	[ratTAValues, ratTAParticipants] = deleteNoSex(ratTAValues, ratTAParticipants);
	[ratSLValues, ratSLParticipants] = deleteNoSex(ratSLValues, ratSLParticipants);
	[ratSPValues, ratSPParticipants] = deleteNoSex(ratSPValues, ratSPParticipants);
	[ratKXValues, ratKXParticipants] = deleteNoSex(ratKXValues, ratKXParticipants);
	[ratValues, ratParticipants] = deleteNoSex(ratValues, ratParticipants);

	% Delete duplicate records
	[sciValues, sciParticipants] = deduplicate(sciValues, sciParticipants);
	[ratTAValues, ratTAParticipants] = deduplicate(ratTAValues, ratTAParticipants);
	[ratSLValues, ratSLParticipants] = deduplicate(ratSLValues, ratSLParticipants);
	[ratSPValues, ratSPParticipants] = deduplicate(ratSPValues, ratSPParticipants);
	[ratKXValues, ratKXParticipants] = deduplicate(ratKXValues, ratKXParticipants);
	[ratValues, ratParticipants] = deduplicate(ratValues, ratParticipants);

	% Fill missing data
	addpath missing;
	sciValues = fillWithMethod(sciValues, nanMethod, true);
	ratTAValues = fillWithMethod(ratTAValues, nanMethod, true);
	ratSLValues = fillWithMethod(ratSLValues, nanMethod, true);
	ratSPValues = fillWithMethod(ratSPValues, nanMethod, true);
	ratKXValues = fillWithMethod(ratKXValues, nanMethod, true);
	ratValues = fillWithMethod(ratValues, nanMethod, true);
	rmpath missing;

	save(savefilepath, 'sciValues', 'sciParticipants', 'ratTAValues', 'ratTAParticipants', 'ratSLValues', 'ratSLParticipants', 'ratSPValues', 'ratSPParticipants', 'ratKXValues', 'ratKXParticipants', 'ratValues', 'ratParticipants', 'measures', 'nanMethod');
end

function [flatVals, flatParts] = flattenStructs(structVals, structParts)
	flatVals = [];
	flatParts = [];
	fields = fieldnames(structVals);
	for i = 1:numel(fields)
		thisParts = structParts.(fields{i});
		thisVals = structVals.(fields{i});
		for j = 1:length(thisParts)
			% Only add the data if the participant hasn't already been added
			if length(flatParts) < 2 || sum(ismember(flatParts, thisParts(j))) == 0
				flatVals = [flatVals; thisVals(j, :)];
				flatParts = [flatParts; thisParts(j)];
			end
		end
	end
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

function [val, part, meas1] = combine(val1, part1, meas1, val2, part2, meas2)
	val = [val1; val2];
	part = [part1; part2];
	assert(isequal(meas1, meas2), 'Combined measures are not the same');
end
