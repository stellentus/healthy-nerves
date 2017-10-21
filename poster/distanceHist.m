% distanceHist prints a histogram of how unusual each participant is
function distanceHist(values1, values2, valuesSCI, comp)
	% Transform data into PCA vector space
	[coefforth, meanorth] = transform(values1);
	score1 = values1*coefforth-meanorth;
	score2 = values2*coefforth-meanorth;
	scoreSCI = valuesSCI*coefforth-meanorth;

	% Truncate to the first comp components
	score1 = score1(:, 1:comp);
	score2 = score2(:, 1:comp);
	scoreSCI = scoreSCI(:, 1:comp);

	len1 = sqrt(sum(score1.^2, 2));
	len2 = sqrt(sum(score2.^2, 2));
	lenSCI = sqrt(sum(scoreSCI.^2, 2));

	nbins = 30;
	[series1, centers] = hist(len1, nbins);
	series2 = hist(len2, centers);
	seriesSCI = hist(lenSCI, centers);
	sum12 = series1 + series2;
	sumAll = sum12 + seriesSCI;

	figure;
	hold on;
	wid = 1;

	bar(centers, sumAll, wid, 'FaceColor', [0.1, 0.7, 0.3], 'EdgeColor', 'none');
	bar(centers, sum12, wid, 'FaceColor', [0.2, 0.2, 0.5], 'EdgeColor', 'none');
	bar(centers, series1, wid, 'FaceColor', [0, 0.7, 0.7], 'EdgeColor', [0, 0.7, 0.7]);

	hold off;
	legend('SCI', 'Arm', 'Leg')
end
