%% batcher detects batch effects.
function [canValues, canParticipants, legValues, legParticipants, japValues, japParticipants, porValues, porParticipants, measures, cri, norm_mutual] = batcher()
	nanMethod = 'IterateRegr';

	% Load the data
	addpath import;
	[canValues, canParticipants, canMeasures] = mefimport('data/human/MedianRepeatedMeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all median, not just repeated
	[legValues, legParticipants, legMeasures] = mefimport('data/human/CPrepeatedmeasures.xlsx', false, false, canonicalNamesNoTE20()); % TODO this could use all CP, not just repeated
	[japValues, japParticipants, japMeasures] = importAllXLSX('none', 'data/Japan');
	[porValues, porParticipants, porMeasures] = importAllXLSX('none', 'data/Portugal');
	rmpath import;

	% Ensure all datasets have the desired measures
	assert(isequal(canMeasures, legMeasures), 'Canadian arm and leg measures are not the same');
	assert(isequal(canMeasures, japMeasures), 'Canadian and Japanese measures are not the same');
	assert(isequal(canMeasures, porMeasures), 'Canadian and Portuguese measures are not the same');
	measures = canMeasures;
	clear legMeasures japMeasures porMeasures;

	% Flatten Japanese and Portuguese data
	[japValues, japParticipants] = flattenStructs(japValues, japParticipants);
	[porValues, porParticipants] = flattenStructs(porValues, porParticipants);

	% Fill missing data
	addpath missing;
	canValues = fillWithMethod(canValues, nanMethod, true);
	legValues = fillWithMethod(legValues, nanMethod, true);
	japValues = fillWithMethod(japValues, nanMethod, true);
	porValues = fillWithMethod(porValues, nanMethod, true);
	rmpath missing;

	% Cluster the data
	labels = [ones(size(canParticipants, 1), 1); ones(size(japParticipants, 1), 1) * 2; repmat(3, size(porParticipants, 1), 1)];
	values = [canValues; japValues; porValues];

	[cri, norm_mutual] = displayBatchResults(labels, kmeans(values, 3), 'k-means');
end

function [cri, norm_mutual] = displayBatchResults(labels, idx, str)
	% Calculate corrected rand index; 0 indicates no batch effects while 1 is perfect batches.
	cri = rand_index(labels, idx, 'adjusted');
	fprintf('The adjusted rand index for %s is %.3f.\n', str, cri);

	% Calculate the normalized mutual information; 0 indicates to batch effects while (I think) 1 is perfect batches.
	addpath info_entropy;
	norm_mutual = nmi(labels, idx);
	rmpath info_entropy;
	fprintf('The normalized mutual information for %s is %.3f.\n', str, norm_mutual);
end

function [flatVals, flatParts] = flattenStructs(structVals, structParts)
	flatVals = [];
	flatParts = [];
	fields = fieldnames(structVals);
	for i = 1:numel(fields)
		flatVals = [flatVals; structVals.(fields{i})];
		flatParts = [flatParts; structParts.(fields{i})];
	end
end

function [dedupVals, dedupParts] = deduplicate(vals, parts)
	[~, indices] = unique(parts, 'first');
	dedupParts = parts(sort(indices));
	dedupVals = vals(sort(indices), :);
end
