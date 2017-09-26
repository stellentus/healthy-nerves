% analyze runs an analysis on the data
function [values, participants, measures, shortNames] = analyze(dataType, deleteNaN, plotType)
	if nargin < 1
		dataType = 'all';
	end

	if nargin < 2
		deleteNaN = true;
	end

	[values, participants, measures, shortNames] = loadData(dataType, deleteNaN);

	% Only plot if a type was provided
	if nargin == 3
		bp(values, measures, shortNames, plotType);
	end
end

% loadData loads the CP data, median data, or both
function [values, participants, measures, shortNames] = loadData(dataType, shouldDeleteNaN)
	switch dataType
		case 'all'
			[participants, measures, cData, mData, uniqueMeasures] = importExcel('data/CPrepeatedmeasures.xlsx', 'data/MedianRepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[values, participants, measures, shortNames] = deleteNaN(participants, measures, cData, mData, uniqueMeasures);
			else
				[values, measures, shortNames] = combineDatasets(measures, cData, 'CP', mData, 'Median', uniqueMeasures);
			end

		case 'cp'
			[participants, measures, values] = importExcel('data/CPrepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[values, participants, measures, shortNames] = deleteNaN(participants, measures, values);
			end

		case 'median'
			[participants, measures, values] = importExcel('data/MedianRepeatedmeasures.xlsx');
			if shouldDeleteNaN
				[values, participants, measures, shortNames] = deleteNaN(participants, measures, values);
			end

        otherwise
			disp('ERROR: data type must be one of ''all'', ''cp'', or ''median''.');
	end
end
