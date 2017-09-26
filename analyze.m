% analyze runs an analysis on the data
function [values, participants, measures, shortNames] = analyze(analysisType)
	[participants, measures, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');

	if nargin == 0
		analysisType = 'data';
	end

	switch analysisType
		case 'data'
			[values, participants, measures, shortNames] = deleteNaN(participants, measures, cData, mData, uniqueMeasures);
		case 'delete'
			[values, participants, measures, shortNames] = deleteNaN(participants, measures, cData, mData, uniqueMeasures);
			bp(values, measures, shortNames)
		case 'Cdelete'
			[values, participants, measures, shortNames] = deleteNaN(participants, measures, cData);
			bp(values, measures, shortNames);
		case 'Mdelete'
			[values, participants, measures, shortNames] = deleteNaN(participants, measures, mData);
			bp(values, measures, shortNames);
		case 'ALS'
			[values, measures, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);
			bp(values, measures, shortNames, alg, 'als')
        otherwise
			disp('ERROR: anaysis type must be one of ''data'', ''delete'', ''Cdelete'', ''Mdelete'', or ''ALS''');
	end
end
