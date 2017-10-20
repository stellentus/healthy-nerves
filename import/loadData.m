% loadData loads the CP data, median data, or both
function [values, participants, measures] = loadData(dataType, shouldDeleteNaN)
	switch dataType
		case 'all'
			[participants, measures, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[participants, data1Matched, data2Matched] = deleteNaN(participants, cData, mData);
				[values, measures] = combineDatasets(measures, data1Matched, 'Leg', data2Matched, 'Arm', uniqueMeasures);
			else
				[values, measures] = combineDatasets(measures, cData, 'Leg', mData, 'Arm', uniqueMeasures);
			end

		case 'leg'
			[values, participants, measures] = loadSingle('data/CPrepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'arm'
			[values, participants, measures] = loadSingle('data/MedianRepeatedmeasures.xlsx', shouldDeleteNaN);

		case 'legSCI'
			% Previously we used SCI_CP.xlsx
			[values, participants, measures] = loadSingle('data/JamesCP.xlsx', shouldDeleteNaN);

		case 'armSCI'
			[values, participants, measures] = loadSingle('data/All_MN_SCI.xlsx', shouldDeleteNaN);

		otherwise
			disp('ERROR: data type must be one of ''all'', ''leg'', or ''arm''.');
	end
end

function [values, participants, measures] = loadSingle(filename, shouldDeleteNaN)
	[participants, measures, values] = importExcel(filename);
	if shouldDeleteNaN
		[participants, values] = deleteNaN(participants, values);
	end
end
