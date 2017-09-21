% analyze runs an analysis on the data
function [measures, matchedParticipants, cDataMatched, mDataMatched] = analyze()
	% Import the data from MEF
	[cData, cMeasureNames, cParticipantNames, cStats] = mefimport('data/CPrepeatedmeasures.xlsx');
	[mData, mMeasureNames, mParticipantNames, mStats] = mefimport('data/MedianRepeatedmeasures.xlsx');

	% Print warnings if something is odd
	stats(mData, mStats, mMeasureNames);
	stats(cData, cStats, cMeasureNames);
	clear mStats cStats; % We don't need them anymore

	% Verify participant names are the same; then only save one list
	indices = verifyNames(cParticipantNames, mParticipantNames);
	[allParticipants, cData, mData] = deleteColumns(indices, cParticipantNames, cData, mData);
	clear cParticipantNames mParticipantNames indices;

	% Verify measure names are the same; then only save one list
	indices = verifyNames(cMeasureNames, mMeasureNames);
	[measures, cData, mData] = deleteRows(indices, cMeasureNames, cData, mData);
	clear cMeasureNames mMeasureNames indices;

	% Handle missing data by deleting NaN columns
	% Create 2 versions of the data:
	%    1. cData and mData with their individual NaN columns removed
	%    2. cDataMatched and mDataMatched with NaN removed from both
	indices = columnsWithNaN(allParticipants, cData, mData);
	[participants, cDataMatched, mDataMatched] = deleteColumns(indices, allParticipants, cData, mData);

	indices = columnsWithNaN(allParticipants, cData);
	[cParticipants, cData] = deleteColumns(indices, allParticipants, cData);

	indices = columnsWithNaN(allParticipants, mData);
	[mParticipants, mData] = deleteColumns(indices, allParticipants, mData);
	clear indices allParticipants;

	% Print all measures correlated between the datasets.
	correlations(measures, cDataMatched, mDataMatched);
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

function [indices, list1] = verifyNames(list1, list2)
	indices = true(1, length(list1));
	for i = 1:length(list1)
		if list1(i) ~= list2
			disp('ERROR: The names at index ' + string(i) + ' don''t match: "' + string(list1(i)) + '" and "' + string(list2(i)) + '".');
			indices(i) = false;
		end
	end
end

function [participants, data1, data2] = deleteColumns(indices, participants, data1, data2)
	data1 = data1(:, indices);
	if nargin == 4
		data2 = data2(:, indices);
	else
		data2 = [];
	end
	participants = participants(indices);
end

function [measures, data1, data2] = deleteRows(indices, measures, data1, data2)
	data1 = data1(indices, :);
	data2 = data2(indices, :);
	measures = measures(indices);
end
