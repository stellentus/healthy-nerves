% mefSRimport imports SR from the provided MEF file, only loading the provided participants, in order.
function [percent, sr, maxCmaps] = mefSRimport(filepath, participants)
	% Import the raw data
	[~, ~, raw] = xlsread(filepath, 'SR');

	% Chop out the y-values and any extra readings
	[~, ncol] = size(raw);
	nparts = (ncol-13)/2;
	rawAll = [raw(1:51, 13:nparts+12); raw(3, nparts+14:2*nparts+13)];

	if nargin > 1
		X = getColumns(rawAll, participants);
		extractedParticipants = string(X(1, :));
		if 0 ~= sum(~strcmp(extractedParticipants', participants))
			disp('WARNING: Participants were not loaded correctly');
		end
	end

	percent = [2:2:98]';
	sr = cell2mat(X(3:51, :));
	maxCmaps = cell2mat(X(52, :)) / 0.02; % Scale these because they're the value at 2%
end

function [X] = getColumns(raw, participants)
	header = string(raw(1, :));

	X = [];
	for j = 1:length(participants)
		ind = find(strcmp(header, participants(j)));
		if ind
			X = [X raw(:, ind)];
		end
	end
end
