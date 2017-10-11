% analyze runs an analysis on the data
function [values, participants, measures] = analyze(dataType, deleteNaN, plotType, alg)
	if nargin < 1
		dataType = 'all';
	end

	if nargin < 2
		deleteNaN = true;
	end

	addpath import;
	[values, participants, measures] = loadData(dataType, deleteNaN);

	if nargin < 4
		alg = 'svd';
	end

	% Only plot if a type was provided
	if nargin >= 3
		figure;
		[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

		addpath analyze;

	    switch plotType
			case 'dist'
				% Print number of STD from mean
				stdDist(length(measures), score, participants, true);
			case 'biplot'
				bp(coeff, score, measures);
			case 'cross'
				dataProj = '';
				switch dataType
					case 'leg'
						dataProj = 'arm';
					case 'arm'
						dataProj = 'leg';
					otherwise
						disp('ERROR: data type must be ''leg'' or ''arm''.');
				end
				[valuesProj, participantsProj] = loadData(dataProj, deleteNaN);
				crosswiseBP(values, valuesProj, measures, participants, participantsProj, alg);
			case 'line'
				dataProj = '';
				switch dataType
					case 'leg'
						dataProj = 'arm';
					case 'arm'
						dataProj = 'leg';
					otherwise
						disp('ERROR: data type must be ''leg'' or ''arm''.');
				end
				[valuesProj, participantsProj] = loadData(dataProj, deleteNaN);
				lineCross(values, valuesProj, participants, participantsProj, alg);
	    end

		rmpath analyze;
	end

	rmpath import;
end
