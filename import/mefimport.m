% mefimport imports the provided MEF file
function [data, measureNames, participantNames, stats] = mefimport(filepath)
	% Import the raw data
	[~, ~, raw] = xlsread(filepath, 'Variables');

	% Get rid of rows and columns that don't help.
	stripped = raw(includedMeasures(), [2,4:7,9:end]);
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

function [inc] = includedMeasures()
	inc = [1:41]; % All rows in the spreadsheet
	inc = inc(inc~=2); % Remove empty row
	inc = inc(inc~=4); % Remove SNAP (µV)
	inc = inc(inc~=11); % Remove Temperature (C)
	inc = inc(inc~=17); % Remove Polarizing current (% threshold)
	inc = inc(inc~=18); % Remove Polarizing current (mA)
	inc = inc(inc~=19); % Remove Age (years)
	inc = inc(inc~=20); % Remove Sex (M=1, F=2)
	% inc = inc(inc~=30); % Remove Hyperpol. I/V slope (missing from SCI)
	inc = inc(inc~=34); % Remove Refractoriness at 2 ms (%) (missing from most SCI)
	inc = inc(inc~=38); % Remove empty row
end
