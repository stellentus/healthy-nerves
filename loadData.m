% loadData loads the CP data, median data, or both
function [values, participants, measures] = loadData(dataType, shouldDeleteNaN)
	switch dataType
		case 'all'
			[participants, measures, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[values, participants, measures] = deleteNaN(participants, measures, cData, mData, uniqueMeasures);
			else
				[values, measures] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);
			end

		case 'cp'
			[values, participants, measures] = loadSingle('data/CPrepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'median'
			[values, participants, measures] = loadSingle('data/MedianRepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'cpSCI'
			[values, participants, measures] = loadSingle('data/SCI_CP.xlsx', shouldDeleteNaN);

		case 'medianSCI'
			[values, participants, measures] = loadSingle('data/All_MN_SCI.xlsx', shouldDeleteNaN);

		otherwise
			disp('ERROR: data type must be one of ''all'', ''cp'', or ''median''.');
	end
end

function [values, participants, measures] = loadSingle(filename, shouldDeleteNaN)
	[participants, measures, values] = importExcel(filename);
	if shouldDeleteNaN
		[values, participants, measures] = deleteNaN(participants, measures, values);
	end
end
