% lineCross creates a plot with a second dataset projected onto the
% first's principal components, with lines between datasets.
function coefforthRef = lineCross(valuesRef, valuesProj, participantsRef, participantsProj, component, alg)
	if nargin < 6
		alg = 'svd';
	end

	[coeffRef, scoreRef] = pca(valuesRef, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforthRef = inv(diag(std(valuesRef)))*coeffRef;
	scoreProj = zscore(valuesProj)*coefforthRef;

	colors = get(gca,'colororder');
	colorMod = length(colors);

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
			color = colors(mod(r, colorMod)+1, :);
			plot([scoreRef(r,component) scoreProj(p,component)], [scoreRef(r,component+1) scoreProj(p,component+1)], '-', 'Color', color);
			plot(scoreRef(r,component), scoreRef(r,component+1), '+', 'Color', color);
			plot(scoreProj(p,component), scoreProj(p,component+1), '*', 'Color', color);
		end
	end
end
