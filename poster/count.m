% count prints the number of remaining participants.
function count(dataType)
	deleteNaN = true;

	[~, participants, measures] = loadData('arm', deleteNaN);
	countOne('Arm', participants, measures);

	[~, participants, measures] = loadData('leg', deleteNaN);
	countOne('Leg', participants, measures);
end

function countOne(displayName, participants, measures)
	disp(sprintf('%s has %d participants', displayName, length(participants)));
	disp(sprintf('%s uses %d measures', displayName, length(measures)));
end
