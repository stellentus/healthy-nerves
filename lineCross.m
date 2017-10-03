% lineCross creates a plot with a second dataset projected onto the
% first's principal components, with lines between datasets.
function coefforthRef = lineCross(valuesRef, valuesProj, participantsRef, participantsProj, alg)
	if nargin < 5
		alg = 'svd';
	end

	[coeffRef, scoreRef] = pca(valuesRef, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforthRef = inv(diag(std(valuesRef)))*coeffRef;
	scoreProj = zscore(valuesProj)*coefforthRef;

	hold on;
	p = 1;
	for r = 1:length(participantsRef)
		% Find the projection participant that matches this reference participant
		for pr = p:length(participantsProj)
			if strcmp(participantsRef(r), participantsProj(pr))
				p = pr;
				break;
			end
		end

		% Make sure a match was actually found before plotting
		if strcmp(participantsRef(r), participantsProj(p))
			plot(scoreRef(r,1:2), scoreProj(p,1:2), '-*');
		end
	end
end
