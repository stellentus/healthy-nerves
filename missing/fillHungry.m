% fillHungry uses two autoencoders, with the second using the first's output.
function [filledX] = fillHungry(missingX, completeX, missingMask, arg)
	[completeIndices, missIndices] = getCompleteIndices(missingX, missingMask);

	inputs = completeX(:, completeIndices);

	addpath ./algorithm

	% Train
	model.params = arg;
	model = neuralnetwork(model);
	model = neuralnetwork(model, inputs, completeX);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	missY = model.Y;

	numSamplesMissing = size(missingX, 1);
	interimX = missingX;
	for j_ind = 1:length(missIndices)
		j = missIndices(j_ind);
		for i = 1:numSamplesMissing
			if isnan(interimX(i, j))
				interimX(i, j) = missY(i, j); % Predict the missing value.
			end
		end
	end

	% Run second autoencoder
	everythingInputs = [completeX; interimX];

	% Train
	model = neuralnetwork(model);
	model = neuralnetwork(model, everythingInputs, everythingInputs); % TODO Or still just train with complete.

	% Predict
	model = neuralnetwork(model, interimX);
	filledX = model.Y;

	rmpath ./algorithm
end
