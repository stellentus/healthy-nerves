% posterCNS prints and displays everything for the poster for CNS
function [participants, cData, mData, measures] = posterCNS()
	addpath import;

	% Import the data from MEF
	[cData, cParticipantNames, cMeasureNames, cStats] = mefimport(pathFor('leg'));
	[mData, mParticipantNames, mMeasureNames, mStats] = mefimport(pathFor('arm'));

	% Verify participant names are the same; then only save one list
	indices = verifyNames(cParticipantNames, mParticipantNames);
	[participants, cData, mData] = deleteRows(indices, cParticipantNames, cData, mData);
	clear cParticipantNames mParticipantNames indices;

	% Verify measure names are the same; then only save one list
	indices = verifyNames(cMeasureNames, mMeasureNames);
	[measures, cData, mData] = deleteColumns(indices, cMeasureNames, cData, mData);
	clear cMeasureNames mMeasureNames indices;

	% Calculate unique columns (e.g. not age and sex)
	unique = [];
	for i = 1:length(measures)
		if ~isequal(cData(:,i), mData(:,i))
			unique = [unique, i];
		end
	end

	[participants, cData, mData] = deleteNaN(participants, cData, mData);

	rmpath import;

	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	redColor = [1 0.1490196078431372549 0];
	yellowColor = [0.98039215686274509804 0.8509803921568627451 0.25882352941176470588];

	x = cData(:, 29);
	y = cData(:, 26);

	plotLinearRegression();
	plotMeanImputation();
	plotPCA();

	% Now define functions in this function because I'm too lazy to deal with scope.

	function plotLinearRegression()
		setPlotOptions();
		ft = polyfit(x, y, 1);
		predictPoint = 93;
		fillPoint = polyval(ft, predictPoint);
		plot(polyval(ft, [0:140]), 'Color', greenColor, 'LineWidth', 3);
		scatter(x, y, 300, '.k');
		line([predictPoint predictPoint], [0 fillPoint], 'Color', yellowColor, 'LineStyle', '--', 'LineWidth', 2);
		line([0 predictPoint], [fillPoint fillPoint], 'Color', yellowColor, 'LineWidth', 2);
	end

	function plotMeanImputation(ind)
		setPlotOptions();
		startPoint = 27;
		maxPlot = startPoint + 30;
		numMissing = 6;
		lastMissing = startPoint + numMissing - 1;

		mVal = mean(x(lastMissing+1:maxPlot));

		ft = polyfit(x(startPoint:maxPlot), y(startPoint:maxPlot), 1);

		plot(polyval(ft, [0:140]), 'Color', greenColor, 'LineWidth', 3);
		scatter(x(startPoint:maxPlot), y(startPoint:maxPlot), 300, '.', 'MarkerEdgeColor', greenColor);
		scatter(x(startPoint:lastMissing), y(startPoint:lastMissing), 100, '.', 'MarkerEdgeColor', redColor);

		mn = ones(numMissing, 1) * mVal;
		scatter(mn, y(startPoint:lastMissing), 300, '.', 'MarkerEdgeColor', greenColor);
		scatter(mn, y(startPoint:lastMissing), 100, '.', 'MarkerEdgeColor', yellowColor);
		filledX = [mn; x(lastMissing+1:maxPlot)];
		filledFt = polyfit(filledX, y(startPoint:maxPlot), 1);
		plot(polyval(filledFt, [0:140]), 'Color', yellowColor, 'LineWidth', 3);

		for i = [1:numMissing]
			ptX = x(startPoint + i - 1);
			ptY = y(startPoint + i - 1);
			line([mVal ptX], [ptY ptY], 'Color', yellowColor, 'LineStyle', '--', 'LineWidth', 1);
		end
	end

	function plotPCA(ind)
		setPlotOptions();
		set(gcf, 'Position', [100, 100, 600, 400]);

		scatter(x, y, 300, '.', 'MarkerEdgeColor', greenColor);

		[coeff, score, latent] = pca([x y]);
		latent = latent/6.3;

		line1XStart = 20;
		shiftFactor1 = [line1XStart 0];
		scaleFactor1 = latent(1);
		arrow(shiftFactor1 + [0 0], shiftFactor1 + scaleFactor1*[coeff(1, 1) coeff(2, 1)], 'Color', [0 0 0], 'LineWidth', 5);

		line2XStart = 80;
		shiftFactor2 = shiftFactor1 + [line2XStart-line1XStart (line2XStart-line1XStart)*coeff(2, 1)/coeff(1, 1)];
		scaleFactor2 = latent(2);
		arrow(shiftFactor2 + [0 0], shiftFactor2 + scaleFactor2*[coeff(1, 2) coeff(2, 2)], 'Color', [0 0 0], 'LineWidth', 2, 'Length', 5);
	end

	function setPlotOptions()
		figure;
		ax = gca;
		ax.YColor = greenColor;
		ax.XColor = greenColor;
		set(gca, 'FontSize', 18);
		hold on;
		ylim([0 80]);
		xlim([20 140]);
		ylabel('Refractoriness at 2.5ms (%)', 'Color', greenColor);
		xlabel('Refractoriness at 2ms (%)', 'Color', greenColor);
	end
end

function [indices, list1] = verifyNames(list1, list2)
	indices = true(length(list1), 1);
	for i = 1:length(list1)
		if list1(i) ~= list2
			disp('ERROR: The names at index ' + string(i) + ' don''t match: "' + string(list1(i)) + '" and "' + string(list2(i)) + '".');
			indices(i) = false;
		end
	end
end

function [participants, data1, data2] = deleteRows(indices, participants, data1, data2)
	data1 = data1(indices, :);
	data2 = data2(indices, :);
	participants = participants(indices);
end

function [measures, data1, data2] = deleteColumns(indices, measures, data1, data2)
	data1 = data1(:, indices);
	data2 = data2(:, indices);
	measures = measures(indices);
end
