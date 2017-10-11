% primaryWeights prints the strongest weights in factor 1
function primaryWeights(name, values, measures)
	alg = 'svd';

	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	plotStart = 1; plotDim = plotStart:(plotStart+2);
	measuresToDisplay = 6;

	% Sort the coefficents by the longest
	weight = sqrt(dot(coeff, coeff, 2));
	[~, corder] = sort(weight, 'descend'); % Order the indices to display
	mdisp = measures(corder(1:measuresToDisplay)); % Get the measures to display, in order
	disp(sprintf('The %d strongest weights for %s are "', measuresToDisplay, name) + strjoin(mdisp, ', ') + '"');
end
