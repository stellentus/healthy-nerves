% ladderPlot plots a ladder for the given component
function ladderPlot(name1, values1, participants1, name2, values2, participants2, component)
	alg = 'svd';

	[coeff1, score1] = pca(values1, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforth1 = inv(diag(std(values1)))*coeff1;
	score2 = zscore(values2)*coefforth1;

	[ind1, ind2] = commonIndices(participants1, participants2);

	score1 = score1(ind1, component);
	score2 = score2(ind2, component);

	figure;
	plotLadder(score1, score2);
end

function [ind1, ind2] = commonIndices(participants1, participants2)
	ind1 = [];
	ind2 = [];

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
			ind1 = [ind1 i1];
			ind2 = [ind2 i2];
		end
	end
end

function plotLadder(data1, data2)
	hold on;

	plot(ones(length(data1)), data1, '.r');
	plot(2*ones(length(data2)), data2, '.b');

	for i = 1:length(data1)
		plot([1 2], [data1(i) data2(i)], 'k');
	end

	axis([0 3 -9 11]);
end
