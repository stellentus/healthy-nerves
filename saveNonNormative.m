% saveNonNormative loads multiple datasets and saves them as a Matlab file.
function saveNonNormative(savefilepath, nanMethod)
	if nargin < 2
		nanMethod = 'IterateCascadeAuto';
		if nargin < 1
			savefilepath = 'bin/non-normative.mat';
		end
	end

	addpath import;

	measures = canonicalNamesNoTE20();

	% Load the data
	[sciValues, sciParticipants, sciNum] = importCleanMEF('data/MEM/SCI/Cross Sectional Data/MEM+MEF data', measures, nanMethod);
	[ratTASPValues, ratTASPParticipants, ratTASPMeasures] = mefimport('data/rat/TA-SP.xlsx', false, false, measures);
	[ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures] = mefimport('data/rat/TA-KX.xlsx', false, false, measures);
	[ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures] = mefimport('data/rat/SOL-SP.xlsx', false, false, measures);
	[ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures] = mefimport('data/rat/SOL-KX.xlsx', false, false, measures);

	% Combine pairs of rat data
	[ratTAValues, ratTAParticipants, ratTAMeasures] = combine(ratTASPValues, ratTASPParticipants, ratTASPMeasures, ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures);
	[ratSLValues, ratSLParticipants, ratSLMeasures] = combine(ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures, ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures);
	[ratSPValues, ratSPParticipants, ratSPMeasures] = combine(ratTASPValues, ratTASPParticipants, ratTASPMeasures, ratSLSPValues, ratSLSPParticipants, ratSLSPMeasures);
	[ratKXValues, ratKXParticipants, ratKXMeasures] = combine(ratTAKXValues, ratTAKXParticipants, ratTAKXMeasures, ratSLKXValues, ratSLKXParticipants, ratSLKXMeasures);
	[ratValues, ratParticipants, ratMeasures] = combine(ratSPValues, ratSPParticipants, ratSPMeasures, ratKXValues, ratKXParticipants, ratKXMeasures);

	% Delete certain participants and fill missing data
	[ratTASPValues, ratTASPParticipants, ratTASPNum] = cleanData(ratTASPValues, ratTASPParticipants, nanMethod, measures);
	[ratTAKXValues, ratTAKXParticipants, ratTAKXNum] = cleanData(ratTAKXValues, ratTAKXParticipants, nanMethod, measures);
	[ratSLSPValues, ratSLSPParticipants, ratSLSPNum] = cleanData(ratSLSPValues, ratSLSPParticipants, nanMethod, measures);
	[ratSLKXValues, ratSLKXParticipants, ratSLKXNum] = cleanData(ratSLKXValues, ratSLKXParticipants, nanMethod, measures);
	[ratTAValues, ratTAParticipants, ratTANum] = cleanData(ratTAValues, ratTAParticipants, nanMethod, measures);
	[ratSLValues, ratSLParticipants, ratSLNum] = cleanData(ratSLValues, ratSLParticipants, nanMethod, measures);
	[ratSPValues, ratSPParticipants, ratSPNum] = cleanData(ratSPValues, ratSPParticipants, nanMethod, measures);
	[ratKXValues, ratKXParticipants, ratKXNum] = cleanData(ratKXValues, ratKXParticipants, nanMethod, measures);
	[ratValues, ratParticipants, ratNum] = cleanData(ratValues, ratParticipants, nanMethod, measures);

	save(savefilepath, 'sciValues', 'sciParticipants', 'sciNum', 'ratTASPValues', 'ratTASPParticipants', 'ratTASPNum', 'ratTAKXValues', 'ratTAKXParticipants', 'ratTAKXNum', 'ratSLSPValues', 'ratSLSPParticipants', 'ratSLSPNum', 'ratSLKXValues', 'ratSLKXParticipants', 'ratSLKXNum', 'ratTAValues', 'ratTAParticipants', 'ratTANum', 'ratSLValues', 'ratSLParticipants', 'ratSLNum', 'ratSPValues', 'ratSPParticipants', 'ratSPNum', 'ratKXValues', 'ratKXParticipants', 'ratKXNum', 'ratValues', 'ratParticipants', 'ratNum', 'measures', 'nanMethod');
end

function [val, part, meas1] = combine(val1, part1, meas1, val2, part2, meas2)
	val = [val1; val2];
	part = [part1; part2];
	assert(isequal(meas1, meas2), 'Combined measures are not the same');
end
