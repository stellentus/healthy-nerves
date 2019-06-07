% mefCDimport imports CD from the provided MEF file, only loading the provided participants, in order.
function [duration, threshold] = mefCDimport(filepath, participants)
	% Import the raw data
	try
		[~, ~, raw] = xlsread(filepath, 'QT');
	catch ex
		duration = [];
		threshold = zeros(1, length(participants));
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

	duration = cell2mat(X(3:7, 1));
	threshold = cell2mat(X(3:7, 2:lastParticipant));
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
