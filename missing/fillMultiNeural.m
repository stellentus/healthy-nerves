% fillMultiNeural uses a separate neural network on each column with missing data. (Very inefficient!)
function [filledX] = fillMultiNeural(missingX, completeX, missingMask, arg)
	if ~isfield(arg, 'ones')
		arg.ones = false;
	end

	[completeIndices, missIndices] = getCompleteIndices(missingX, missingMask);

	inputs = completeX(:, completeIndices);
	outputs = completeX(:, missIndices);

	addpath ./algorithm

	% Train
	model.params = arg;
	model = neuralnetwork(model);
	model = neuralnetwork(model, inputs, outputs);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	missY = model.Y;

	rmpath ./algorithm

	filledX = missingX;
	filledX(:, missIndices) = missY(:, 1:length(missIndices)); % Predict the missing value.
end
