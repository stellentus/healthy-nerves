% fillAutoencoder uses an autoencoder to fill the values.
function [filledX, covr] = fillAutoencoder(missingX, completeX, mask, originalMissingX, missingMask, arg)
	trainX = [];
	trainY = [];
	testX = [];
	testY = [];
	yindices = [];

	% Put columns with missing data into Y; otherwise put them into X.
	for j = 1:size(missingX, 2)
		if sum(missingMask(:, j)) == 0
			trainX = [trainX; completeX(:, j)];
			testX = [testX; missingX(:, j)];
		else
			trainY = [trainY; completeX(:, j)];
			yindices = [yindices; j];
		end
	end

	addpath ./algorithm

	for j = i:size(yindices)
		model.name = 'neuralnetwork';
		model = neuralnetwork(model);
		model = neuralnetwork(model, trainX, trainY(j));
		model = neuralnetwork(model, testX);
		testY = [testY; model.ytest];
		clear model;
	end

	rmpath ./algorithm


	covr = calcCov(completeX, filledX);
end
