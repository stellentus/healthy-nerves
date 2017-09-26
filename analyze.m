% analyze runs an analysis on the data
function [values, participants, measures, shortNames] = analyze(analysisType)
	[cData, mData, participants, measures, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');

	if nargin == 0
		analysisType = 'data';
	end

	switch analysisType
		case 'data'
			[values, participants, measures, shortNames] = dataWithoutNaN(cData, mData, participants, measures, uniqueMeasures);
		case 'delete'
			[values, participants, measures, shortNames] = biplotWithoutNaN(cData, mData, participants, measures, uniqueMeasures);
		case 'Cdelete'
			[values, participants, measures, shortNames] = biplotCDataWithoutNaN(cData, participants, measures);
		case 'Mdelete'
			[values, participants, measures, shortNames] = biplotMDataWithoutNaN(mData, participants, measures);
		case 'ALS'
			[values, measures, shortNames] = biplotWithALS(cData, mData, measures, uniqueMeasures);
        otherwise
			disp('ERROR: anaysis type must be one of ''data'', ''delete'', ''Cdelete'', ''Mdelete'', or ''ALS''');
	end
end

function [values, participants, measures, shortNames] = biplotCDataWithoutNaN(cData, participants, measures)
	[values, participants, measures, shortNames] = dataIndividualWithoutNaN(cData, participants, measures)
	biplotBasic(values, measures, shortNames);
end

function [values, participants, measures, shortNames] = biplotMDataWithoutNaN(mData, participants, measures)
	[values, participants, measures, shortNames] = dataIndividualWithoutNaN(mData, participants, measures)
	biplotBasic(values, measures, shortNames);
end

function [values, participants, measures, shortNames] = dataIndividualWithoutNaN(values, particpants, measures)
	% Handle missing values by deleting NaN rows
	indices = rowsWithNaN(participants, values);
	[participants, values] = deleteRows(indices, participants, values);
	clear indices;

	shortNames = shortenNames(measures);
end

function biplotBasic(values, measures, shortNames)
	[coeff, score] = pca(values, 'VariableWeights', 'variance');
	biplot(coeff(:,1:3), 'scores', score(:,1:3), 'varlabels', cellstr(shortNames));
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

function [values, participants, measures, shortNames] = biplotWithoutNaN(cData, mData, allParticipants, measures, uniqueMeasures)
	[values, participants, measures, shortNames] = dataWithoutNaN(cData, mData, allParticipants, measures, uniqueMeasures);
	biplotBasic(values, measures, shortNames)
end

function [values, measures, shortNames] = biplotWithALS(cData, mData, measures, uniqueMeasures)
	[values, measures, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);

	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', 'als');
	biplot(coeff(:,1:3), 'scores', score(:,1:3), 'varlabels', cellstr(shortNames));

	% Print the short and long names of measures.
	disp([measures(1:35)' shortNames(1:35)']);
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
