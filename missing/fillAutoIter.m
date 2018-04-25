% fillAutoIter uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoIter(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'epochs')
		arg.epochs = 10;
	end

	% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
	filledX = fillNaive(missingX, completeX, missingMask, arg);

	% Now make sure future iterations don't reset the NaN values
	if isfield(arg, 'handleNaN')
		arg.handleNaN = '';
	end

	% Iterate through predictions
	for i=1:arg.epochs
		filledX = fillAutoencoder(filledX, completeX, missingMask, arg);
		filledX = updateKnownValues(filledX, missingX, missingMask); % Repair the known values from missingX
	end
end
