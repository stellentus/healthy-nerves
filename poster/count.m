% count prints the number of remaining participants.
function count(displayName, participants, measures)
	disp(sprintf('%s has %d participants with %d measures', displayName, length(participants), length(measures)));
end
