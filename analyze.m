% analyze runs an analysis on the data
function [measures, participants, values, shortNames] = analyze(analysisType)
	[measures, participants, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');

	if nargin == 0
		analysisType = 'data';
	end

	switch analysisType
		case 'data'
			[measures, participants, values, shortNames] = dataWithoutNaN(measures, participants, cData, mData, uniqueMeasures);
		case 'delete'
			[measures, participants, values, shortNames] = biplotWithoutNaN(measures, participants, cData, mData, uniqueMeasures);
		case 'Cdelete'
			[measures, participants, values, shortNames] = biplotCDataWithoutNaN(measures, participants, cData);
		case 'Mdelete'
			[measures, participants, values, shortNames] = biplotMDataWithoutNaN(measures, participants, mData);
		case 'ALS'
			[measures, values, shortNames] = biplotWithALS(measures, cData, mData, uniqueMeasures);
		otherwise % 'delete' is the default
			disp('ERROR: anaysis type must be one of ''data'', ''delete'', ''Cdelete'', ''Mdelete'', or ''ALS''');
	end
end

function [measures, participants, values, shortNames] = biplotCDataWithoutNaN(measures, participants, cData)
	[measures, participants, values, shortNames] = biplotIndividualWithoutNaN(measures, participants, cData);
end

function [measures, participants, values, shortNames] = biplotMDataWithoutNaN(measures, participants, mData)
	[measures, participants, values, shortNames] = biplotIndividualWithoutNaN(measures, participants, mData);
end

function [measures, participants, values, shortNames] = biplotIndividualWithoutNaN(measures, participants, values)
	% Handle missing values by deleting NaN rows
	indices = rowsWithNaN(participants, values);
	[participants, values] = deleteRows(indices, participants, values);
	clear indices;

	shortNames = shortenNames(measures);

	[coeff,score] = pca(values, 'VariableWeights', 'variance');
	biplot(coeff(:,1:3), 'scores', score(:,1:3), 'varlabels', cellstr(shortNames));

	% Print the short and long names of measures.
	disp([measures' shortNames']);
end

function [measures, participants, values, shortNames] = dataWithoutNaN(measures, allParticipants, cData, mData, uniqueMeasures)
	% Handle missing data by deleting NaN rows
	indices = rowsWithNaN(allParticipants, cData, mData);
	[participants, cDataMatched, mDataMatched] = deleteRows(indices, allParticipants, cData, mData);

	% Print all measures correlated between the datasets.
	correlations(measures, cDataMatched, mDataMatched);

	% Combine the arm and leg data into one dataset
	[measures, values, shortNames] = combineDatasets(measures, cDataMatched, 'CP', mDataMatched, 'Median', uniqueMeasures);
end

function [measures, participants, values, shortNames] = biplotWithoutNaN(measures, allParticipants, cData, mData, uniqueMeasures)
	[measures, participants, values, shortNames] = dataWithoutNaN(measures, allParticipants, cData, mData, uniqueMeasures);

	[coeff,score] = pca(values, 'VariableWeights', 'variance');
	biplot(coeff(:,1:3), 'scores', score(:,1:3), 'varlabels', cellstr(shortNames));

	% Print the short and long names of measures.
	disp([measures(1:35)' shortNames(1:35)']);
end

function [measures, values, shortNames] = biplotWithALS(measures, cData, mData, uniqueMeasures)
	[measures, values, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);

	[coeff,score] = pca(values, 'VariableWeights', 'variance', 'algorithm', 'als');
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
