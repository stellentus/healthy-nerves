% fillWithMethod fills NaN values, using the requested fill method.
function [values] = fillWithMethod(values, method, args)
	if nargin < 3
		args = struct();
	end

	[completeIndices, missIndices] = getCompleteIndices(values, ~isnan(values), 1);

	completeX = values(completeIndices, :);
	missingX = values(missIndices, :);
	missingMask = isnan(missingX);

	switch method
		case 'CCA'  % This doesn't actually delete those rows. It just passes them as-is.
			func = @fillCCA;
			args = mergeArgs(args, struct());
		case 'Naive'
			func = @fillNaive;
			args = mergeArgs(args, struct('handleNaN', 'mean', 'useMissingMaskForNaNFill', true));
		case 'PCA'
			func = @fillPCA;
			args = mergeArgs(args, struct('k', 6, 'VariableWeights', 'variance'));
		case 'IteratePCA'
			func = @fillIterate;
			args = mergeArgs(args, struct('method', @fillPCA, 'handleNaN', 'mean', 'iterations', 20, 'args', struct('k', 6, 'VariableWeights', 'variance', 'algorithm', 'eig')));
		case 'Regr'
			func = @fillRegr;
			args = mergeArgs(args, struct('handleNaN', 'mean'));
		case 'IterateRegr'
			func = @fillIterate;
			args = mergeArgs(args, struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
		case 'MI'
			func = @fillMI;
			args = mergeArgs(args, struct('number', 10, 'length', 100));
		case 'Autoencoder'
			func = @fillAutoencoder;
			args = mergeArgs(args, struct('nh', 6, 'trainMissingRows', true, 'handleNaN', 'mean'));
		case 'IterateAutoencoder'
			func = @fillIterate;
			args = mergeArgs(args, struct('method', @fillAutoencoder, 'handleNaN', 'mean', 'iterations', 5, 'args', struct('nh', 6, 'trainMissingRows', true)));
		case 'CascadeAuto'
			func = @fillCascadeAuto;
			args = mergeArgs(args, struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500));
		case 'IterateCascadeAuto'
			func = @fillIterate;
			args = mergeArgs(args, struct('method', @fillCascadeAuto, 'iterations', 2, 'args', struct('nh', 6, 'rho', 0.99, 'epsilon', 1e-7, 'epochs', 500)));
		case 'delete'
			values = completeX;
			return
		otherwise
			return
	end

	filledX = func(missingX, completeX, missingMask, args);
	values = [completeX; filledX];
end

function [args] = fillWithMethod(args, argDefault)
	fields = fieldnames(argDefault);
	for i = 1:numel(fields)
		if ~isfield(args, fields{i})
			args.(fields{i}) = argDefault.(fields{i});
		end
	end
end
