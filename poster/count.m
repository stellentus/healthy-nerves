% count prints the number of remaining participants.
function count(name1, participants1, measures1, name2, participants2, measures2)
	countOne(name1, participants1, measures1);
	countOne(name2, participants2, measures2);
end

function countOne(displayName, participants, measures)
	disp(sprintf('%s has %d participants', displayName, length(participants)));
	disp(sprintf('%s uses %d measures', displayName, length(measures)));
end
