% fillIterate uses a provided method to iterate.
% If arg.method is not a function pointer, the code will crash.
function [filledX] = fillIterate(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'iterations')
		arg.iterations = 10;
	end
	if ~isfield(arg, 'iterEps')
		arg.iterEps = 1;
	end
	if ~isfield(arg, 'args')
		% This is used as the argument to the iterated code.
		arg.args = struct();
	end

	% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
	filledX = fillNaive(missingX, completeX, missingMask, arg);

	% Iterate through predictions
	for i=1:arg.iterations
		prevX = filledX;

		filledX = arg.method(filledX, completeX, missingMask, arg.args);
		filledX = updateKnownValues(filledX, missingX, missingMask); % Repair the known values from missingX

		% Stop after convergence
		iterEps = norm(prevX-filledX);
		if iterEps < arg.iterEps
			% fprintf(' (converged after %d) ', i);
			break
		end
	end
end
