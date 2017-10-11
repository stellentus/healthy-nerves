% mefimport imports the provided MEF file
function [data, measureNames, participantNames, stats] = mefimport(filepath)
	% Import the raw data
	[~, ~, raw] = xlsread(filepath, 'Variables');

	% Get rid of rows and columns that don't help.
	stripped = raw([1,3,5:16,19:37,39:end], [2,4:7,9:end]);
	clear raw;

	% Import the columns we care about
	measureNames = string(stripped([2:end], 1));
	averages = cell2mat(stripped([2:end], 2));
	counts = cell2mat(stripped([2:end], 3));
	SDs = cell2mat(stripped([2:end], 4));
	SEs = cell2mat(stripped([2:end], 5));
	stats = struct('average', averages, 'count', counts, 'SD', SDs, 'SE', SEs);
	clear averages counts SDs SEs;

	% Import the rows we care about
	participantNames = string(stripped(1, [6:end]));

	% Import the data
	data = cell2mat(stripped([2:end], [6:end]));

	% Clean up the measure names
	measureNames = replace(measureNames, '\', ' ');

	verifyStats(data, stats, measureNames);

	% Transpose everything
	data = data.';
	measureNames = measureNames.';
	participantNames = participantNames.';
end

% verifyStats confirms the MEF stats match what Matlab calculates
function verifyStats(data, stats, names)
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
