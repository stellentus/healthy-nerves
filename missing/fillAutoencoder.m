% fillAutoencoder uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoencoder(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'trainMissingColumns')
		arg.trainMissingColumns = false;
	end
	if ~isfield(arg, 'trainMissingRows')
		arg.trainMissingRows = false;
	end

	if arg.trainMissingColumns
		inputIndices = getCompleteIndices(missingX, missingMask); % Input only complete indices
	else
		inputIndices = [1:size(missingX, 2)]; % Input all indices
	end

	if arg.trainMissingRows
		% If the appropriate flag is set, this function will fill NaN with some naive value. Otherwise, it does nothing.
		missingX = fillNaive(missingX, completeX, missingMask, arg);
		trainData = [completeX; missingX]; % all data
	else
		trainData = completeX;             % complete data
	end

	addpath ./algorithm

	% Train
	model.params = arg;
	model = neuralnetwork(model);
	model = neuralnetwork(model, trainData(:, inputIndices), trainData);

	% Predict
	model = neuralnetwork(model, missingX(:, inputIndices));
	filledX = model.Y;

	rmpath ./algorithm
end
