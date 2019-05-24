% saveNonNormative loads multiple datasets and saves them as a Matlab file.
function saveNonNormative(nanMethod, savefilepath)
	if nargin < 2
		savefilepath = 'bin/non-normative.mat';
		if nargin < 1
			nanMethod = 'Mean';
		end
	end

	addpath import;

	% Load the data
	[sciValues, sciParticipants, sciMeasures] = importAllXLSX('none', 'data/MEM/SCI/Cross Sectional Data/MEM+MEF data');
	[ratTASPValues, ratTASPParticipants, ratTASPMeasures] = mefimport('data/rat/TA-SP.xlsx', false, false, canonicalNamesNoTE20());
	[ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures] = mefimport('data/rat/TA-KX.xlsx', false, false, canonicalNamesNoTE20());
	[ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures] = mefimport('data/rat/SOL-SP.xlsx', false, false, canonicalNamesNoTE20());
	[ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures] = mefimport('data/rat/SOL-KX.xlsx', false, false, canonicalNamesNoTE20());

	% Combine pairs of rat data
	[ratTAValues, ratTAParticipants, ratTAMeasures] = combine(ratTASPValues, ratTASPParticipants, ratTASPMeasures, ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures);
	[ratSLValues, ratSLParticipants, ratSLMeasures] = combine(ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures, ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures);
	[ratSPValues, ratSPParticipants, ratSPMeasures] = combine(ratTASPValues, ratTASPParticipants, ratTASPMeasures, ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures);
	[ratKXValues, ratKXParticipants, ratKXMeasures] = combine(ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures, ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures);
	[ratValues, ratParticipants, ratMeasures] = combine(ratSPValues, ratSPParticipants, ratSPMeasures, ratKXValues, ratKXParticipants, ratKXMeasures);

	% Ensure all datasets have the desired measures
	assert(isequal(sciMeasures, ratTAMeasures), 'SCI and rat TA measures are not the same');
	assert(isequal(sciMeasures, ratSLMeasures), 'SCI and rat SL measures are not the same');
	assert(isequal(sciMeasures, ratMeasures), 'SCI and rat all measures are not the same');
	measures = sciMeasures;

	% Flatten SCI data
	[sciValues, sciParticipants] = flattenStructs(sciValues, sciParticipants);

	% Delete people who have no sex
	[sciValues, sciParticipants] = deleteNoSex(sciValues, sciParticipants);
	[ratTASPValues, ratTASPParticipants] = deleteNoSex(ratTASPValues, ratTASPParticipants);
	[ratTAKXValues, ratTAKXParticipants] = deleteNoSex(ratTAKXValues, ratTAKXParticipants);
	[ratSLSPValues, ratSLSPParticipants] = deleteNoSex(ratSLSPValues, ratSLSPParticipants);
	[ratSLKXValues, ratSLKXParticipants] = deleteNoSex(ratSLKXValues, ratSLKXParticipants);
	[ratTAValues, ratTAParticipants] = deleteNoSex(ratTAValues, ratTAParticipants);
	[ratSLValues, ratSLParticipants] = deleteNoSex(ratSLValues, ratSLParticipants);
	[ratSPValues, ratSPParticipants] = deleteNoSex(ratSPValues, ratSPParticipants);
	[ratKXValues, ratKXParticipants] = deleteNoSex(ratKXValues, ratKXParticipants);
	[ratValues, ratParticipants] = deleteNoSex(ratValues, ratParticipants);

	% Delete duplicate records
	[sciValues, sciParticipants] = deduplicate(sciValues, sciParticipants);
	[ratTASPValues, ratTASPParticipants] = deduplicate(ratTASPValues, ratTASPParticipants);
	[ratTAKXValues, ratTAKXParticipants] = deduplicate(ratTAKXValues, ratTAKXParticipants);
	[ratSLSPValues, ratSLSPParticipants] = deduplicate(ratSLSPValues, ratSLSPParticipants);
	[ratSLKXValues, ratSLKXParticipants] = deduplicate(ratSLKXValues, ratSLKXParticipants);
	[ratTAValues, ratTAParticipants] = deduplicate(ratTAValues, ratTAParticipants);
	[ratSLValues, ratSLParticipants] = deduplicate(ratSLValues, ratSLParticipants);
	[ratSPValues, ratSPParticipants] = deduplicate(ratSPValues, ratSPParticipants);
	[ratKXValues, ratKXParticipants] = deduplicate(ratKXValues, ratKXParticipants);
	[ratValues, ratParticipants] = deduplicate(ratValues, ratParticipants);

	rmpath import;

	% Fill missing data
	addpath missing;
	sciValues = fillWithMethod(sciValues, nanMethod, true);
	ratTASPValues = fillWithMethod(ratTASPValues, nanMethod, true);
	ratTAKXValues = fillWithMethod(ratTAKXValues, nanMethod, true);
	ratSLSPValues = fillWithMethod(ratSLSPValues, nanMethod, true);
	ratSLKXValues = fillWithMethod(ratSLKXValues, nanMethod, true);
	ratTAValues = fillWithMethod(ratTAValues, nanMethod, true);
	ratSLValues = fillWithMethod(ratSLValues, nanMethod, true);
	ratSPValues = fillWithMethod(ratSPValues, nanMethod, true);
	ratKXValues = fillWithMethod(ratKXValues, nanMethod, true);
	ratValues = fillWithMethod(ratValues, nanMethod, true);
	rmpath missing;

	sciNum = size(sciValues, 1);
	ratTASPNum = size(ratTASPValues, 1);
	ratTAKXNum = size(ratTAKXValues, 1);
	ratSLSPNum = size(ratSLSPValues, 1);
	ratSLKXNum = size(ratSLKXValues, 1);
	ratTANum = size(ratTAValues, 1);
	ratSLNum = size(ratSLValues, 1);
	ratSPNum = size(ratSPValues, 1);
	ratKXNum = size(ratKXValues, 1);
	ratNum = size(ratValues, 1);

	save(savefilepath, 'sciValues', 'sciParticipants', 'sciNum', 'ratTASPValues', 'ratTASPParticipants', 'ratTASPNum', 'ratTAKXValues', 'ratTAKXParticipants', 'ratTAKXNum', 'ratSLSPValues', 'ratSLSPParticipants', 'ratSLSPNum', 'ratSLKXValues', 'ratSLKXParticipants', 'ratSLKXNum', 'ratTAValues', 'ratTAParticipants', 'ratTANum', 'ratSLValues', 'ratSLParticipants', 'ratSLNum', 'ratSPValues', 'ratSPParticipants', 'ratSPNum', 'ratKXValues', 'ratKXParticipants', 'ratKXNum', 'ratValues', 'ratParticipants', 'ratNum', 'measures', 'nanMethod');
end

function [val, part, meas1] = combine(val1, part1, meas1, val2, part2, meas2)
	val = [val1; val2];
	part = [part1; part2];
	assert(isequal(meas1, meas2), 'Combined measures are not the same');
end
