% fillPCAIter uses PCA with numerous iterations to fill the values.
%   filledX is the best-guess filling of the missing values (with known values used when possible).
function [filledX] = fillPCAIter(missingX, completeX, missingMask, args)
	if ~isfield(args, 'k')
		args.k = 6;
	end
	if ~isfield(args, 'VariableWeights')
		args.VariableWeights = ones(1, size(missingX, 2));
	end
	if ~isfield(args, 'algorithm')
		args.algorithm = 'als';
	end
	if ~isfield(args, 'epochs')
		args.epochs = 100;
	end

	% If the appropriate flag is set, this function will fill NaN with some naive value before doing PCA. Otherwise, it does nothing.
	filledX = fillNaive(missingX, completeX, missingMask, args);

	for i=1:args.epochs
		% Train
		X = [filledX; completeX];
		[coeff, score, ~, ~, ~, mu] = pca(X, 'VariableWeights', args.VariableWeights, 'algorithm', args.algorithm);
		coeff = coeff';

		% Predict
		dim = size(filledX, 1);
		filledX = score(1:dim, 1:args.k) * coeff(1:args.k, :) + repmat(mu, dim, 1); % Get PCA for entire matrix
		filledX = updateKnownValues(filledX, missingX, missingMask); % Repair the known values from missingX
	end
end
