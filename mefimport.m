% mefimport imports the provided MEF file
function [data, measureNames, participantNames, stats] = mefimport(filepath)
	% Import the raw data
	[~, ~, raw] = xlsread(filepath, 'Variables');

	% Get rid of rows and columns that don't help.
	stripped = raw([1,3,5:16,19:37,39:end], [2,4:7,9:end]);
	clear raw;

	% Import the columns we care about
	measureNames = stripped([2:end], 1);
	averages = stripped([2:end], 2);
	counts = stripped([2:end], 3);
	SDs = stripped([2:end], 4);
	SEs = stripped([2:end], 5);
	stats = struct('average', averages, 'count', counts, 'SD', SDs, 'SE', SEs);
	clear averages counts SDs SEs;

	% Import the rows we care about
	participantNames = stripped(1, [6:end]);

	% Import the data
	data = stripped([2:end], [6:end]);

	clear stripped;
end
