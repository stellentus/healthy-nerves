% bp creates biplots
function bp(values, measures, alg)
	if nargin < 4
		alg = 'svd';
	end

	plotStart = 1; plotDim = plotStart:(plotStart+2);
	measuresToDisplay = 1:8;

	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	% Sort the coefficents by the longest
	weight = sqrt(dot(coeff(:,plotDim), coeff(:,plotDim), 2));
	[~, corder] = sort(weight, 'descend'); % Order the indices to display
	cdisp = corder(measuresToDisplay); % Get the indices to display, in order

	biplot(coeff(cdisp, plotDim), 'scores', score(:, plotDim), 'varlabels', cellstr(measures(cdisp)));
end
