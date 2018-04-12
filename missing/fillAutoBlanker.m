% fillAutoBlanker uses an autoencoder (but with a different number of inputs and outputs).
function [filledX, covr] = fillAutoBlanker(missingX, completeX, mask, originalMissingX, missingMask, arg)
	filledX = missingX;
	[numSamplesMissing, numFeatures] = size(missingX);

	if ~isfield(arg, 'ones')
		arg.ones = false;
	end
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
	missY = model.Y;

	rmpath ./algorithm

	for j = 1:numFeatures
		% Skip this column if it has no missing values
		if sum(missingMask(:, j)) == 0
			continue
		end

		for i = 1:numSamplesMissing
			if isnan(filledX(i, j))
				% fprintf('Filling (%d, %d) with %f (true: %f)\n', i, j, missY(i, j), originalMissingX(i, j))
				filledX(i, j) = missY(i, j); % Predict the missing value.
			end
		end
	end

	covr = calcCov(completeX, filledX);
end
