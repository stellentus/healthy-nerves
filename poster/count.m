% count prints the number of remaining participants.
function count(displayName, participants, measures)
	disp(sprintf('%s has %d participants', displayName, length(participants)));
	disp(sprintf('%s uses %d measures', displayName, length(measures)));
end
