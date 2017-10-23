% loadData loads the CP data, median data, or both
function [values, participants, measures] = loadData(dataType, shouldDeleteNaN)
	switch dataType
		case 'all'
			[values, participants, measures] = importTwo(pathFor('leg'), pathFor('arm'), shouldDeleteNaN);

		otherwise
			[values, participants, measures] = mefimport(pathFor(dataType), shouldDeleteNaN);
	end
end
