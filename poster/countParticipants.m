% countParticipants prints the number of remaining participants.
function countParticipants(displayName, participants, measures)
	disp(sprintf('%s has %d participants with %d measures', displayName, length(participants), length(measures)));
end
