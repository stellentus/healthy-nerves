% transform calculates a PCA transform
function [coeff, m] = transform(values)
	coeff = pca(values, 'VariableWeights', 'variance');
	coeff = inv(diag(std(values)))*coeff./std(values)';
	m = mean(values)*coeff;
end
