% mefimport imports the provided MEF file
function [data, participantNames, measureNames, stats, age, sex] = mefimport(filepath, shouldDeleteNaN, displayWarnings, expectedNames)
	if nargin < 4
		expectedNames = canonicalNames();
		if nargin < 3
			displayWarnings = true;
			if nargin < 2
				shouldDeleteNaN = false;
			end
		end
	end

	% Import the raw data
	[~, ~, raw] = xlsread(filepath, 'Variables');

	% Get rid of rows and columns that don't help.
	measureNames = string(raw(:, 2));
	[includedRows, measureNames] = includedMeasuresByName(measureNames, expectedNames);
	stripped = raw(includedRows, [2,4:7,9:end]);
	stripped(strcmp(stripped, '#N/A')) = {NaN}; % Change any N/A to zero.

	% Import the columns we care about
	averages = cell2mat(stripped(:, 2));
	counts = cell2mat(stripped(:, 3));
	SDs = cell2mat(stripped(:, 4));
	SEs = cell2mat(stripped(:, 5));
	stats = struct('average', averages, 'count', counts, 'SD', SDs, 'SE', SEs);
	clear averages counts SDs SEs;

	% Import the rows we care about
	participantNames = string(raw(1, [9:end]));

	% Import the data
	data = cell2mat(stripped(:, [6:end]));

	% Now grab age and sex
	age = cell2mat(raw(19, [9:end]));
	sex = cell2mat(raw(20, [9:end]));
	clear raw;

	if displayWarnings
		verifyStats(data, stats, measureNames);
	end

	% Transpose everything
	data = data.';
	measureNames = measureNames.';
	participantNames = participantNames.';

	if shouldDeleteNaN
		[participantNames, data, ~, indices] = deleteNaN(participantNames, data);
		age = age(indices);
		sex = sex(indices);
	end
end

% verifyStats confirms the MEF stats match what Matlab calculates
function verifyStats(data, stats, names)
	compare(names, stats.average, mean(data, 2, 'omitnan'), 'an average');
	compare(names, stats.SD, std(data, 0, 2, 'omitnan'), 'a standard deviation');
	compare(names, stats.SE, std(data, 0, 2, 'omitnan')./sqrt(stats.count), 'a standard error');
end

function compare(names, expected, actual, statName)
	for i = 1:length(actual)
		if abs(actual(i)-expected(i)) > 1e4*eps(min(abs(actual(i)),abs(expected(i)))) || isnan(actual(i)) || isnan(expected(i))
			fprintf('"%s" has %s of %d instead of %d.\n', names(i), statName, actual(i), expected(i));
		end
	end
end

function [inc] = includedMeasures()
	inc = [1:41]; % All rows in the spreadsheet
	inc = inc(inc~=2); % Remove empty row
	inc = inc(inc~=4); % Remove SNAP (µV)
	% inc = inc(inc~=11); % Remove Temperature (C)
	inc = inc(inc~=17); % Remove Polarizing current (% threshold)
	inc = inc(inc~=18); % Remove Polarizing current (mA)
	% inc = inc(inc~=19); % Remove Age (years)
	% inc = inc(inc~=20); % Remove Sex (M=1, F=2)
	% inc = inc(inc~=30); % Remove Hyperpol. I/V slope (missing from SCI)
	% inc = inc(inc~=34); % Remove Refractoriness at 2 ms (%) (missing from most SCI)
	inc = inc(inc~=38); % Remove empty row
end

function [inc, measures] = includedMeasuresByName(names, expectedNames)
	names = replace(names, "\", " ");

	if length(intersect(expectedNames, names)) ~= length(expectedNames)
		warning('Not all of the canonical measures were found')
	end

	inc = [];
	for name = expectedNames'
		ind = find(ismember(names, name));
		inc = [inc ind];
	end

	measures = names(inc);

	if ~isequal(measures, expectedNames)
		warning('Measures are not same as canonical.')
	end
end
