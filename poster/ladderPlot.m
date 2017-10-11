% ladderPlot plots a ladder for 6 components
function ladderPlot(name1, values1, participants1, name2, values2, participants2)
	alg = 'svd';

	[coeff1, scores1] = pca(values1, 'VariableWeights', 'variance', 'algorithm', alg);

	coefforth1 = inv(diag(std(values1)))*coeff1;
	scores2 = zscore(values2)*coefforth1;

	[ind1, ind2] = commonIndices(participants1, participants2);

	scores1 = scores1(ind1, :);
	scores2 = scores2(ind2, :);

	figure;

	for i = 1:6
		subplot(3, 2, i);
		plotLadder(scores1(:, i), name1, scores2(:, i), name2);
	end

	ax=axes('Units', 'Normal', 'Position', [.075 .075 .85 .85], 'Visible', 'off', 'FontSize', 18);
	set(get(ax, 'Title'), 'Visible', 'on');
	title('Arm/Leg Correlations in the First 6 Factors');
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

function plotLadder(data1, name1, data2, name2)
	hold on;

	plot(ones(length(data1)), data1, '.r');
	plot(2*ones(length(data2)), data2, '.b');

	for i = 1:length(data1)
		plot([1 2], [data1(i) data2(i)], 'k');
	end

	axis([0.5 2.5 -inf inf]);
	xticks([1 2]);
	xticklabels({name1, name2});
end
