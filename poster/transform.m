% transform calculates a PCA transform
function [coeff, m] = transform(values, alg)
	if nargin < 2
		alg = 'svd';
	end

	coeff = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);
	coeff = inv(diag(std(values)))*coeff./std(values)';
	m = mean(values)*coeff;
end
