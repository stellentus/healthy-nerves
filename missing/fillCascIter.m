% fillCascIter uses a cascading autoencoder and iterates.
function [filledX] = fillCascIter(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'iterations')
		arg.iterations = 10;
	end
	if ~isfield(arg, 'iterEps')
		arg.iterEps = 2;
	end

	% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
	filledX = fillNaive(missingX, completeX, missingMask, arg);

	% Now make sure future iterations don't reset the NaN values
	if isfield(arg, 'handleNaN')
		arg.handleNaN = '';
	end

	% Iterate through predictions
	for i=1:arg.iterations
		prevX = filledX;

		filledX = fillCascadeAuto(filledX, completeX, missingMask, arg);
		filledX = updateKnownValues(filledX, missingX, missingMask); % Repair the known values from missingX

		% Stop after convergence
		iterEps = norm(prevX-filledX);
		if iterEps < arg.iterEps
			% fprintf(' (converged after %d) ', i);
			break
		end
	end
end
