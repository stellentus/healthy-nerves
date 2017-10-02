% analyze runs an analysis on the data
function [values, participants, measures] = analyze(dataType, deleteNaN, plotType, alg)
	if nargin < 1
		dataType = 'all';
	end

	if nargin < 2
		deleteNaN = true;
	end

	[values, participants, measures] = loadData(dataType, deleteNaN);

	if nargin < 4
		alg = 'svd';
	end

	% Only plot if a type was provided
	if nargin >= 3
		figure;
		[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	    switch plotType
			case 'dist'
				% Print number of STD from mean
				stdDist(length(measures), score, participants, true);
			case 'biplot'
				bp(coeff, score, measures);
	    end
	end
end

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
