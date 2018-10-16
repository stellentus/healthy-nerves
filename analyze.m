% analyze runs an analysis on the data
function [values, participants, measures] = analyze(dataType, nanMethod, plotType, alg)
	if nargin < 1
		dataType = 'all';
	end

	if nargin < 2
		nanMethod = 'delete';
	end

	shouldDeleteNaN = strcmp(nanMethod, 'delete');

	addpath import;
	if strcmp(dataType, 'all')
		[cData, mData, participants, measures] = importTwo(pathFor('leg'), pathFor('arm'), shouldDeleteNaN);

		if shouldDeleteNaN
			[participants, cData, mData] = deleteNaN(participants, cData, mData);
		end

		[values, measures] = combineTwo(cData, mData, measures);
		clear cData, mData;
	else
		[values, participants, measures] = mefimport(pathFor(dataType), shouldDeleteNaN);
	end

	values = fillWithMethod(values, nanMethod);

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
				[valuesProj, participantsProj] = mefimport(pathFor(dataProj), shouldDeleteNaN);
				values = fillWithMethod(valuesProj, nanMethod);
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
				[valuesProj, participantsProj] = mefimport(pathFor(dataProj), shouldDeleteNaN);
				values = fillWithMethod(valuesProj, nanMethod);
				lineCross(values, valuesProj, participants, participantsProj, 1, alg);
	    end

		rmpath analyze;
	end

	rmpath import;
end
