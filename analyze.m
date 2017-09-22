% analyze runs an analysis on the data
function [measures, participants, values, shortNames] = analyze()
	[measures, allParticipants, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');

	% Handle missing data by deleting NaN rows
	% Create 2 versions of the data:
	%    1. cData and mData with their individual NaN rows removed
	%    2. cDataMatched and mDataMatched with NaN removed from both
	indices = rowsWithNaN(allParticipants, cData, mData);
	[participants, cDataMatched, mDataMatched] = deleteRows(indices, allParticipants, cData, mData);

	indices = rowsWithNaN(allParticipants, cData);
	[cParticipants, cData] = deleteRows(indices, allParticipants, cData);

	indices = rowsWithNaN(allParticipants, mData);
	[mParticipants, mData] = deleteRows(indices, allParticipants, mData);
	clear indices allParticipants;

	% Print all measures correlated between the datasets.
	correlations(measures, cDataMatched, mDataMatched);

	% Delete all of the variables we created, but don't actually care to use
	clear cParticipants, cData; % We don't actually look at CP independently
	clear mParticipants, mData; % We don't actually look at median independently

	% Combine the arm and leg data into one dataset
	[measures, values, shortNames] = combineDatasets(measures, cDataMatched, 'CP', mDataMatched, 'Median', uniqueMeasures);
	clear cDataMatched, mDataMatched;

	% Extract factors
	values = extractFactors(values);
end

function biplotWithALS(measures, cData, mData, uniqueMeasures)
	[~, values, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);

	[coeff,score] = pca(values, 'VariableWeights', 'variance', 'algorithm', 'als');
	biplot(coeff(:,1:3), 'scores', score(:,1:3), 'varlabels', cellstr(shortNames));

	% Print the short and long names of measures.
	disp([measures' shortNames(1:35)']);
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
