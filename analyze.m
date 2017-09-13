% analyze runs an analysis on the data
function analyze()
	% Import the data from MEF
	[cData, cMeasureNames, cParticipantNames, cStats] = mefimport('data/CPrepeatedmeasures.xlsx');
	[mData, mMeasureNames, mParticipantNames, mStats] = mefimport('data/MedianRepeatedmeasures.xlsx');

	% Print warnings if something is odd
	stats(mData, mStats, mMeasureNames);
	stats(cData, cStats, cMeasureNames);
	clear mStats cStats; % We don't need them anymore

	% Verify participant names are the same; then only save one list
	[ok, participants] = verifyNames(cParticipantNames, mParticipantNames);
	clear cParticipantNames mParticipantNames;
	if ~ok
		return
	end

	% Verify measure names are the same; then only save one list
	[ok, measures] = verifyNames(cMeasureNames, mMeasureNames);
	clear cMeasureNames mMeasureNames;
	if ~ok
		return
	end

	% Handle missing data
	[cData, mData, participants] = deleteMissingRows(cData, mData, participants);
end

% stats confirms the MEF stats match what Matlab calculates
function stats(data, stats, names)
	compare(names, stats.average, mean(data, 2, 'omitnan'), 'an average');
	compare(names, stats.SD, std(data, 0, 2, 'omitnan'), 'a standard deviation');
	compare(names, stats.SE, std(data, 0, 2, 'omitnan')./sqrt(stats.count), 'a standard error');
end

function compare(names, expected, actual, statName)
	for i = 1:length(actual)
		if abs(actual(i)-expected(i)) > 1e4*eps(min(abs(actual(i)),abs(expected(i))))
			disp('"' + names(i) + '" has ' + statName + ' of ' + actual(i) + ' instead of ' + expected(i) + '.');
		end
	end
end

function [ok, list1] = verifyNames(list1, list2)
	ok = true;
	for i = 1:length(list1)
		if list1(i) ~= list2
			disp('ERROR: The names at index ' + string(i) + ' don''t match: "' + string(list1(i)) + '" and "' + string(list2(i)) + '".');
			ok = false;
		end
	end
end
