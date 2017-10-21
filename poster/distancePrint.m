% distancePrint prints participants in order of distance from mean
function distancePrint(values1, participants1, valuesSCI, participantsSCI, comp)
	% Transform data into PCA vector space
	[coefforth, meanorth] = transform(values1);
	score1 = values1*coefforth-meanorth;
	scoreSCI = valuesSCI*coefforth-meanorth;

	% Truncate to the first comp components
	scoreComp1 = score1(:, 1:comp);
	scoreCompSCI = scoreSCI(:, 1:comp);

	% As if the double division by the standard deviation in transform() isn't enough, we divide by std
	% This is so that each of the components is weighted equally in the final hypersphere
	scoreComp1 = scoreComp1./std(scoreComp1);
	scoreCompSCI = scoreCompSCI./std(scoreCompSCI);

	% Calculate vector length
	lenComp1 = sqrt(sum(scoreComp1.^2, 2));
	lenCompSCI = sqrt(sum(scoreCompSCI.^2, 2));

	% Sort the participants by the farthest
	[~, lenCompOrder] = sort(lenComp1, 'ascend'); % Order the indices to display
	lenComp1 = lenComp1(lenCompOrder);
	participants1 = participants1(lenCompOrder);
	scoreComp1 = scoreComp1(lenCompOrder, :);

	disp(sprintf('The %d healthy participants in order of distance are:', length(lenComp1)));
	disp(scoreComp1);

	disp(sprintf('The %d SCI participants are:', length(lenCompSCI)));
	disp(scoreCompSCI);

	disp(sprintf('The length of the last two are %.3f and %.3f.', lenComp1(end-1), lenComp1(end)));
	% AR07N (FES!!) and SA02A(2) are outside. TR06S and SA02A(1) are inside.
end
