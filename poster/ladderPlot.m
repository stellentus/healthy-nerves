% ladderPlot plots a ladder for 5 components
function ladderPlot(name1, values1, participants1, name2, values2, participants2)
	[coeff, m] = transform(values1);
	scores1 = values1*coeff-m;
	scores2 = values2*coeff-m;

	[ind1, ind2] = commonIndices(participants1, participants2);

	scores1 = scores1(ind1, :);
	scores2 = scores2(ind2, :);

	figure;

	for i = 1:5
		subplot(3, 2, i);
		plotLadder(scores1(:, i), name1, scores2(:, i), name2, i);
	end

	ax=axes('Units', 'Normal', 'Position', [.075 .095 .85 .85], 'Visible', 'off', 'FontSize', 18);
	set(get(ax, 'Title'), 'Visible', 'on');
	title('Arm/Leg Correlations in the First 5 Factors');
end

function plotLadder(data1, name1, data2, name2, component)
	hold on;

	plot(ones(length(data1)), data1, '.r');
	plot(2*ones(length(data2)), data2, '.b');

	for i = 1:length(data1)
		plot([1 2], [data1(i) data2(i)], 'k');
	end

	axis([0.5 2.5 -inf inf]);
	xticks([1 2]);
	xticklabels({name1, name2});

	[r, p] = corrcoef(data1, data2);
	if p(1, 2) < 0.005
		title(sprintf('Component %d: r^2=%.3f', component, r(1, 2)^2));
	else
		title(sprintf('Component %d: Not correlated', component));
	end
end
