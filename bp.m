% bp creates biplots
function bp(values, measures, shortNames, alg)
	if nargin < 4
		alg = 'svd';
	end
	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);
	biplot(coeff(:,1:3), 'scores', score(:,1:3), 'varlabels', cellstr(shortNames));
end
