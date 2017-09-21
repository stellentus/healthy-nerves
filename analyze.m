% analyze runs an analysis on the data
function [measures, participants, cDataMatched, mDataMatched] = analyze()
	[measures, allParticipants, cData, mData] = import();

	% Handle missing data by deleting NaN rows
	% Create 2 versions of the data:
	%    1. cData and mData with their individual NaN rows removed
	%    2. cDataMatched and mDataMatched with NaN removed from both
	indices = rowsWithNaN(allParticipants, cData, mData);
	[participants, cDataMatched, mDataMatched] = deleteRows(indices, allParticipants, cData, mData);

	indices = rowsWithNaN(allParticipants, cData);
	[cParticipants, cData] = deleteRows(indices, allParticipants, cData);

	indices = rowsWithNaN(allParticipants, mData);
	[mParticipants, mData] = deleteRows(indices, allParticipants, mData);
	clear indices allParticipants;

	% Print all measures correlated between the datasets.
	correlations(measures, cDataMatched, mDataMatched);

	% Delete all of the variables we created, but don't actually care to use
	clear cParticipants, cData; % We don't actually look at CP independently
	clear mParticipants, mData; % We don't actually look at median independently
end

function [measures, participants, cData, mData] = import()
	% Import the data from MEF
	[cData, cMeasureNames, cParticipantNames, cStats] = mefimport('data/CPrepeatedmeasures.xlsx');
	[mData, mMeasureNames, mParticipantNames, mStats] = mefimport('data/MedianRepeatedmeasures.xlsx');

	% Print warnings if something is odd
	stats(cData, cStats, cMeasureNames);
	stats(mData, mStats, mMeasureNames);
	clear mStats cStats; % We don't need them anymore

	% Transpose everything
	cData = cData.';
	mData = mData.';
	cMeasureNames = cMeasureNames.';
	mMeasureNames = mMeasureNames.';
	cParticipantNames = cParticipantNames.';
	mParticipantNames = mParticipantNames.';

	% Verify participant names are the same; then only save one list
	indices = verifyNames(cParticipantNames, mParticipantNames);
	[participants, cData, mData] = deleteRows(indices, cParticipantNames, cData, mData);
	clear cParticipantNames mParticipantNames indices;

	% Verify measure names are the same; then only save one list
	indices = verifyNames(cMeasureNames, mMeasureNames);
	[measures, cData, mData] = deleteColumns(indices, cMeasureNames, cData, mData);
	clear cMeasureNames mMeasureNames indices;
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
	indices = true(length(list1), 1);
	for i = 1:length(list1)
		if list1(i) ~= list2
			disp('ERROR: The names at index ' + string(i) + ' don''t match: "' + string(list1(i)) + '" and "' + string(list2(i)) + '".');
			indices(i) = false;
		end
	end
end

function [participants, data1, data2] = deleteRows(indices, participants, data1, data2)
	data1 = data1(indices, :);
	if nargin == 4
		data2 = data2(indices, :);
	else
		data2 = [];
	end
	participants = participants(indices);
end

function [measures, data1, data2] = deleteColumns(indices, measures, data1, data2)
	data1 = data1(:, indices);
	data2 = data2(:, indices);
	measures = measures(indices);
end
