% crosswiseBP creates a biplot with a second dataset projected onto the
% first's principal components
function crosswiseBP(valuesRef, valuesProj, measures, participantsRef, participantsProj, alg)
	if nargin < 6
		alg = 'svd';
	end

	[coeffRef, scoreRef] = pca(valuesRef, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforthRef = inv(diag(std(valuesRef)))*coeffRef;
	scoreProj = zscore(valuesProj)*coefforthRef;

	subplot(2,2,1);
	bp(coeffRef, scoreRef, measures);
	title('Reference Data');

	subplot(2,2,2);
	bp(coeffRef, scoreProj, measures);
	title('Projected Data');

	subplot(2,2,3);
	stdDist(length(measures), scoreRef, participantsRef);
	title('Reference Histogram');

	subplot(2,2,4);
	stdDist(length(measures), scoreProj, participantsProj);
	title('Projected Histogram');
end
