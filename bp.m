% bp creates biplots
function bp(values, measures, shortNames, alg)
	if nargin < 4
		alg = 'svd';
	end

	plotDim = 1:3;

	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);
	biplot(coeff(:, plotDim), 'scores', score(:, plotDim), 'varlabels', cellstr(shortNames));
end
