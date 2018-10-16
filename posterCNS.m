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

	% Calculate my missing recovery @2ms
	addpath missing;
	cData(99, 29); % Delete my recov @2ms because it shouldn't be there.
	[completeIndices, missIndices] = getCompleteIndices(cData, ~isnan(cData), 1);
	missingX = cData(missIndices, :);
	completeX = cData(completeIndices, :);
	filledX = fillIterate(missingX, completeX, ~isnan(missingX), struct('method', @fillRegr, 'handleNaN', 'mean', 'iterations', 20, 'args', struct()));
	myVal = filledX(end, 29);

	% Now delete missing data rows
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
	plotMyRecoveryCycle(myVal);
	plotMyTE();

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
		setGlobalPlotOptions();
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

function plotMyRecoveryCycle(myVal)
	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	redColor = [1 0.1490196078431372549 0];
	yellowColor = [0.98039215686274509804 0.8509803921568627451 0.25882352941176470588];

	recovX = [2.5, 3.200000048, 4, 5, 6.300000191, 7.900000095, 10, 13, 18, 24, 32, 42, 56, 75, 100, 140, 200];
	recovY = [27.81999969, -9.039999962, -20.84000015, -25.81999969, -24.79999924, -22.45000076, -17.72999954, -14.42000008, -0.180000007, 5.429999828, 9.789999962, 12.85999966, 14.10000038, 12.10999966, 6.75, 4.269999981, 1.460000038];
	missX = [2.0];
	missY = [myVal];

	A = [recovX(9), recovY(9)];
	B = [recovX(10), recovY(10)];
	xIntercept2 = A(1)-A(2)*(A(1)-B(1))/(A(2)-B(2));
	A = [recovX(1), recovY(1)];
	B = [recovX(2), recovY(2)];
	xIntercept1 = A(1)-A(2)*(A(1)-B(1))/(A(2)-B(2));

	setGlobalPlotOptions();
	set(gcf, 'Position', [100, 100, 800, 400]);
	set(gca, 'XScale', 'log')
	line([.5 200], [0 0], 'LineWidth', .25, 'Color', greenColor); % y==0 line
	line([1.5 1.5], [-100 100], 'LineStyle', '--', 'LineWidth', 2, 'Color', yellowColor);
	line([xIntercept1 xIntercept1], [-100 100], 'LineStyle', '--', 'LineWidth', 2, 'Color', yellowColor);
	line([xIntercept2 xIntercept2], [-100 100], 'LineStyle', '--', 'LineWidth', 2, 'Color', yellowColor);

	plot(recovX, recovY, '.-', 'Color', greenColor, 'MarkerSize', 30);
	line([A(1) missX], [A(2) missY], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', greenColor);
	plot(missX, missY, 'o', 'Color', greenColor, 'MarkerSize', 10, 'MarkerFaceColor', yellowColor);
	ylim([-30 80]);
	xlim([.5 200]);
	ylabel('Threshold Change (%)', 'Color', greenColor);
	xlabel('Delay (ms)', 'Color', greenColor);
end

function plotMyTE()
	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	redColor = [1 0.1490196078431372549 0];
	yellowColor = [0.98039215686274509804 0.8509803921568627451 0.25882352941176470588];

	teX1 = [0, 9, 10, 11, 15, 20, 26, 33, 41, 50, 60, 70, 80, 90, 100, 109, 110, 111, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210];
	teX2 = [0, 9, 10, 11, 20, 30, 40, 50, 60, 70, 80, 90, 100, 109, 110, 111, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210];
	ted40Y = [0, 0, 40.27999878, 44.43999863, 53.09999847, 58.97999954, 64.16999817, 65.26000214, 62.36000061, 55.93000031, 51.11000061, 46.13000107, 44.59000015, 44.08000183, 46, 45.04000092, 3.089999914, 3.640000105, -8.869999886, -13.26000023, -14.96000004, -15.05000019, -13.56000042, -10.59000015, -7.420000076, -6.070000172, -4.300000191, -3.039999962];
	teh40Y = [0, 0, -41.93999863, -44.04999924, -60.29999924, -78.79000092, -91.47000122, -99.44000244, -106.8499985, -111.0800018, -119.0899963, -126.1900024, -128.6000061, -130.3300018, -90.25, -87.90000153, -66.83000183, -48.31999969, -32.90999985, -18.21999931, -9.43999958, -1.929999948, 5.199999809, 7.75, 8.970000267, 8.600000381];
	ted20Y = [0, 0, 18.57999992, 22.54999924, 30.81999969, 36.13999939, 36.52000046, 38.54000092, 37.20000076, 33.15999985, 30.87999916, 28.86000061, 27.53000069, 27.95000076, 8.199999809, 6.760000229, 0.600000024, -5.519999981, -6.860000134, -8.119999886, -6.489999771, -6.769999981, -5.989999771, -2.950000048, -3.190000057, -1.620000005];
	teh20Y = [0, 0, -20.52000046, -22.34000015, -29.12000084, -39.36000061, -43.22000122, -48.13999939, -48.45999908, -49.93999863, -49.79999924, -50.70000076, -50.59999847, -51.54999924, -31.44000053, -30.94000053, -18.30999947, -8.029999733, -1.879999995, 2.75, 6.409999847, 6.5, 6.369999886, 5.860000134, 3.49000001, 2.799999952];

	setGlobalPlotOptions();
	set(gcf, 'Position', [100, 100, 800, 400]);
	line([0 210], [0 0], 'LineWidth', .25, 'Color', greenColor); % y==0 line

	plot(teX1, ted40Y, '.-', 'Color', greenColor, 'MarkerSize', 20);
	plot(teX2, teh40Y, '.-', 'Color', greenColor, 'MarkerSize', 20);
	plot(teX2, ted20Y, '.-', 'Color', greenColor, 'MarkerSize', 20);
	plot(teX2, teh20Y, '.-', 'Color', greenColor, 'MarkerSize', 20);
	ylim([-150 80]);
	xlim([0 210]);
	ylabel('Threshold Reduction (%)', 'Color', greenColor);
	xlabel('Delay (ms)', 'Color', greenColor);
end

function setGlobalPlotOptions()
	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	figure;
	ax = gca;
	ax.YColor = greenColor;
	ax.XColor = greenColor;
	set(gca, 'FontSize', 18);
	hold on;
end
