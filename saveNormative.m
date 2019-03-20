% saveNormative loads multiple datasets and confirms they can be concatenated.
function saveNormative(pathPrefix, nanMethod)
	if nargin < 3
		nanMethod = 'IterateRegr';
		if nargin < 2
			pathPrefix = 'data/';
			if nargin < 1
				savefilepath = 'bin/batch-normative.mat';
			end
		end
	end

	% Load the data
	addpath import;
	[canValues, canParticipants, canMeasures] = mefimport(strcat(pathPrefix, 'human/MedianRepeatedMeasures.xlsx'), false, false, canonicalNamesNoTE20()); % TODO this could use all median, not just repeated
	[legValues, legParticipants, legMeasures] = mefimport(strcat(pathPrefix, 'human/CPrepeatedmeasures.xlsx'), false, false, canonicalNamesNoTE20()); % TODO this could use all CP, not just repeated
	[japValues, japParticipants, japMeasures] = importAllXLSX('none', strcat(pathPrefix, 'Japan'));
	[porValues, porParticipants, porMeasures] = importAllXLSX('none', strcat(pathPrefix, 'Portugal'));
	rmpath import;

	% Ensure all datasets have the desired measures
	assert(isequal(canMeasures, legMeasures), 'Canadian arm and leg measures are not the same');
	assert(isequal(canMeasures, japMeasures), 'Canadian and Japanese measures are not the same');
	assert(isequal(canMeasures, porMeasures), 'Canadian and Portuguese measures are not the same');
	measures = canMeasures;

	% Flatten Japanese and Portuguese data
	[japValues, japParticipants] = flattenStructs(japValues, japParticipants);
	[porValues, porParticipants] = flattenStructs(porValues, porParticipants);

	% Delete people who have no sex
	[canValues, canParticipants] = deleteNoSex(canValues, canParticipants);
	[legValues, legParticipants] = deleteNoSex(legValues, legParticipants);
	[japValues, japParticipants] = deleteNoSex(japValues, japParticipants);
	[porValues, porParticipants] = deleteNoSex(porValues, porParticipants);

	% Delete duplicate records
	[canValues, canParticipants] = deduplicate(canValues, canParticipants);
	[legValues, legParticipants] = deduplicate(legValues, legParticipants);
	[japValues, japParticipants] = deduplicate(japValues, japParticipants);
	[porValues, porParticipants] = deduplicate(porValues, porParticipants);

	% Fill missing data
	addpath missing;
	canValues = fillWithMethod(canValues, nanMethod, true);
	legValues = fillWithMethod(legValues, nanMethod, true);
	japValues = fillWithMethod(japValues, nanMethod, true);
	porValues = fillWithMethod(porValues, nanMethod, true);
	rmpath missing;

	save(savefilepath, 'canValues', 'canParticipants', 'japValues', 'japParticipants', 'porValues', 'porParticipants', 'legValues', 'legParticipants', 'measures', 'nanMethod')
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
