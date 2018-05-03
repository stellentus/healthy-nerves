% mefTEimport imports TE from the provided MEF file, only loading the provided participants, in order.
function [delayTEd40, delayTEh40, delayTEd20, delayTEh20, TEd40, TEh40, TEd20, TEh20] = mefTEimport(filepath, participants)
	% Import the raw data
	[~, ~, raw] = xlsread(filepath, 'TE');
	% delays = raw(:, 1);

	X = getColumns(raw, participants);
	extractedParticipants = string(X(1, 2:size(X, 2)));
	if 0 ~= sum(~strcmp(extractedParticipants', participants))
		disp('WARNING: Participants were not loaded correctly');
	end

	lastParticipant = size(X, 2);

	delayTEd40 = cell2mat(X(3:30, 1));
	delayTEh40 = cell2mat(X(32:57, 1));
	delayTEd20 = cell2mat(X(59:84, 1));
	delayTEh20 = cell2mat(X(86:111, 1));

	TEd40 = cell2mat(X(3:30, 2:lastParticipant));
	TEh40 = cell2mat(X(32:57, 2:lastParticipant));
	TEd20 = cell2mat(X(59:84, 2:lastParticipant));
	TEh20 = cell2mat(X(86:111, 2:lastParticipant));
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
