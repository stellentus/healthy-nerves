% bp creates biplots
function bp(values, measures, shortNames, alg)
	if nargin < 4
		alg = 'svd';
	end

	plotDim = 1:3;
	measuresToDisplay = 1:8;

	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	% Sort the coefficents by the longest
	weight = sqrt(dot(coeff(:,plotDim), coeff(:,plotDim), 2));
	[~, eigOrder] = sort(weight, 'descend');

	biplot(coeff(eigOrder(measuresToDisplay), plotDim), 'scores', score(:, plotDim), 'varlabels', cellstr(shortNames(eigOrder(measuresToDisplay))));
end
