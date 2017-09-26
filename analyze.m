% analyze runs an analysis on the data
function [values, participants, measures, shortNames] = analyze(analysisType)
	[participants, measures, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');

	if nargin == 0
		analysisType = 'data';
	end

	switch analysisType
		case 'data'
			[values, participants, measures, shortNames] = dataWithoutNaN(cData, mData, participants, measures, uniqueMeasures);
		case 'delete'
			[values, participants, measures, shortNames] = dataWithoutNaN(cData, mData, participants, measures, uniqueMeasures);
			bp(values, measures, shortNames)
		case 'Cdelete'
			[values, participants, measures, shortNames] = dataIndividualWithoutNaN(cData, participants, measures)
			bp(values, measures, shortNames);
		case 'Mdelete'
			[values, participants, measures, shortNames] = dataIndividualWithoutNaN(mData, participants, measures)
			bp(values, measures, shortNames);
		case 'ALS'
			[values, measures, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);
			bp(values, measures, shortNames, alg, 'als')
        otherwise
			disp('ERROR: anaysis type must be one of ''data'', ''delete'', ''Cdelete'', ''Mdelete'', or ''ALS''');
	end
end

function [values, participants, measures, shortNames] = dataIndividualWithoutNaN(values, particpants, measures)
	% Handle missing values by deleting NaN rows
	indices = rowsWithNaN(participants, values);
	[participants, values] = deleteRows(indices, participants, values);
	clear indices;

	shortNames = shortenNames(measures);
end

function [values, participants, measures, shortNames] = dataWithoutNaN(cData, mData, allParticipants, measures, uniqueMeasures)
	% Handle missing data by deleting NaN rows
	indices = rowsWithNaN(allParticipants, cData, mData);
	[participants, cDataMatched, mDataMatched] = deleteRows(indices, allParticipants, cData, mData);

	% Print all measures correlated between the datasets.
	correlations(measures, cDataMatched, mDataMatched);

	% Combine the arm and leg data into one dataset
	[values, measures, shortNames] = combineDatasets(measures, cDataMatched, 'CP', mDataMatched, 'Median', uniqueMeasures);
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
