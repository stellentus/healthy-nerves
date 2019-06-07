% mefRCimport imports RC from the provided MEF file, only loading the provided participants, in order.
function [delay, rc] = mefRCimport(filepath, participants)
	% Import the raw data
	try
		[~, ~, raw] = xlsread(filepath, 'RC');
	catch ex
		delay = [];
		rc = zeros(1, length(participants));
		return
	end

	if nargin > 1
		X = getColumns(raw, participants);
		extractedParticipants = string(X(1, 2:size(X, 2)));
		if 0 ~= sum(~strcmp(extractedParticipants', participants))
			disp('WARNING: Participants were not loaded correctly');
		end
	else
		X = raw(:, [1 8:end]);
	end

	lastParticipant = size(X, 2);

	delay = cell2mat(X(3:20, 1));
	rc = cell2mat(X(3:20, 2:lastParticipant));
end

function [X] = getColumns(raw, participants)
	header = string(raw(1, :));

	X = raw(:, 1);
	for j = 1:length(participants)
		ind = find(strcmp(header, participants(j)));
		if ind
			X = [X raw(:, ind)];
		end
	end
end
