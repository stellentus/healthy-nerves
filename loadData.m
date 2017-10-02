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
			[participants, measures, values] = importExcel('data/CPrepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[values, participants, measures] = deleteNaN(participants, measures, values);
			end

		case 'median'
			[participants, measures, values] = importExcel('data/MedianRepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[values, participants, measures] = deleteNaN(participants, measures, values);
			end

		otherwise
			disp('ERROR: data type must be one of ''all'', ''cp'', or ''median''.');
	end
end
