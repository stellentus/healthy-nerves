% fillAutoBlanker uses an autoencoder (but with a different number of inputs and outputs).
function [filledX] = fillAutoBlanker(missingX, completeX, mask, originalMissingX, missingMask, arg)
	[numSamplesMissing, numFeatures] = size(missingX);

	model.params = arg;

	allX = [completeX; missingX];
	mn = nanmean(allX);
	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:size(allX, 1)
			if isnan(allX(i, j))
				allX(i, j) = mn(j);
			end
		end
	end

	addpath ./algorithm

	% Train
	model = neuralnetwork(model);
	model = neuralnetwork(model, allX, allX);

	% Predict
	model = neuralnetwork(model, missingX);
	filledX = model.Y;

	rmpath ./algorithm
end
