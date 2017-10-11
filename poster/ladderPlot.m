% ladderPlot plots a ladder for the given component
function ladderPlot(name1, values1, participants1, name2, values2, participants2, component)
	alg = 'svd';

	[coeff1, score1] = pca(values1, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforth1 = inv(diag(std(values1)))*coeff1;
	score2 = zscore(values2)*coefforth1;

	score1 = score1(:, component);
	score2 = score2(:, component);

	figure;
	hold on;

	plot(ones(length(score1)), score1, '.r');
	plot(2*ones(length(score2)), score2, '.b');

	p = 1;
	for i1 = 1:length(participants1)
		% Find the projection participant that matches this reference participant
		for i2 = p:length(participants2)
			if strcmp(participants1(i1), participants2(i2))
				p = i2;
				break;
			end
		end

		% Make sure a match was actually found before plotting
		if strcmp(participants1(i1), participants2(p))
			plot([1 2], [score1(i1) score2(i2)], 'k');
		end
	end

	axis([0 3 -9 11]);
end
