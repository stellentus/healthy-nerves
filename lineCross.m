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
			Make a short vector with some test data to figure out what's plotting wrong in 3D
			x = [scoreRef(r,1), scoreProj(p,1)];
			y = [scoreRef(r,2), scoreProj(p,2)];
			z = [scoreRef(r,3), scoreProj(p,3)];
			plot3(x, y, z, '-*');
		end
	end

	xlabel('Component 1');
	ylabel('Component 2');
	zlabel('Component 3');
end
