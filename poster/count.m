% count prints the number of remaining participants.
function count(dataType)
	deleteNaN = true;

	countOne('arm', deleteNaN);
	countOne('leg', deleteNaN);
end

function countOne(dataType, deleteNaN)
	displayName = dataType;
	displayName(1) = upper(displayName(1));

	[values, participants, measures] = loadData(dataType, deleteNaN);

	disp(sprintf('%s has %d participants', displayName, length(participants)));
	disp(sprintf('%s uses %d measures', displayName, length(measures)));
end
