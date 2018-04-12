% fillAutoencoder uses an autoencoder (but with a different number of inputs and outputs).
function [filledX, covr] = fillAutoencoder(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);

	if ~isfield(arg, 'ones')
		arg.ones = false;
	end
	model.params = arg;

	missIndices = [];
	completeIndices = [];
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == numSamplesMissing
			completeIndices = [completeIndices; j];
		else
			missIndices = [missIndices; j];
		end
	end

	inputs = completeX(:, completeIndices);

	addpath ./algorithm

	% Train
	model = neuralnetwork(model);
	model = neuralnetwork(model, inputs, completeX);

	% Predict
	model = neuralnetwork(model, missingX(:, completeIndices));
	missY = model.Y;

	rmpath ./algorithm

	for j_ind = 1:length(missIndices)
		j = missIndices(j_ind);
		for i = 1:numSamplesMissing
			if isnan(filledX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, missY(i, j), originalMissingX(i, j))
				filledX(i, j) = missY(i, j); % Predict the missing value.
			end
		end
	end


	covr = calcCov(completeX, filledX);
end
