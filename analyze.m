% analyze runs an analysis on the data
function [values, participants, measures, shortNames] = analyze(analysisType)
	[participants, measures, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');

	if nargin == 0
		analysisType = 'data';
	end

	switch analysisType
		case 'data'
			[values, participants, measures, shortNames] = dataWithoutNaN(participants, measures, cData, mData, uniqueMeasures);
		case 'delete'
			[values, participants, measures, shortNames] = dataWithoutNaN(participants, measures, cData, mData, uniqueMeasures);
			bp(values, measures, shortNames)
		case 'Cdelete'
			[values, participants, measures, shortNames] = dataIndividualWithoutNaN(participants, measures, cData)
			bp(values, measures, shortNames);
		case 'Mdelete'
			[values, participants, measures, shortNames] = dataIndividualWithoutNaN(participants, measures, mData)
			bp(values, measures, shortNames);
		case 'ALS'
			[values, measures, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);
			bp(values, measures, shortNames, alg, 'als')
        otherwise
			disp('ERROR: anaysis type must be one of ''data'', ''delete'', ''Cdelete'', ''Mdelete'', or ''ALS''');
	end
end

function [values, participants, measures, shortNames] = dataIndividualWithoutNaN(particpants, measures, data)
	% Handle missing data by deleting NaN rows
	indices = rowsWithNaN(participants, data);
	[participants, data] = deleteRows(indices, participants, data);
	clear indices;

	shortNames = shortenNames(measures);
end

function [values, participants, measures, shortNames] = dataWithoutNaN(participants, measures, data1, data2, uniqueMeasures)
	% Handle missing data by deleting NaN rows
	indices = rowsWithNaN(participants, data1, data2);
	[participants, data1Matched, data2Matched] = deleteRows(indices, participants, data1, data2);

	% Print all measures correlated between the datasets.
	correlations(measures, data1Matched, data2Matched);

	% Combine the arm and leg data into one dataset
	[values, measures, shortNames] = combineDatasets(measures, data1Matched, 'CP', data2Matched, 'Median', uniqueMeasures);
end

function [participants, data1, data2] = deleteRows(indices, participants, data1, data2)
	data1 = data1(indices, :);
	if nargin == 4
		data2 = data2(indices, :);
	else
		data2 = [];
	end
	participants = participants(indices);
end
