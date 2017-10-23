% loadData loads the CP data, median data, or both
function [values, participants, measures] = loadData(dataType, shouldDeleteNaN)
	switch dataType
		case 'all'
			[values, participants, measures] = importTwo('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'leg'
			[values, measures, participants] = mefimport('data/CPrepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'arm'
			[values, measures, participants] = mefimport('data/MedianRepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'legSCI'
			% Previously we used SCI_CP.xlsx
			[values, measures, participants] = mefimport('data/JamesCP.xlsx', shouldDeleteNaN);

		case 'armSCI'
			[values, measures, participants] = mefimport('data/All_MN_SCI.xlsx', shouldDeleteNaN);

		otherwise
			disp('ERROR: data type must be one of ''all'', ''leg'', or ''arm''.');
	end
end
