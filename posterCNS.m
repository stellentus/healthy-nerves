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
	ft = polyfit(x, y, 1);
	predictPoint = 93;
	fillPoint = polyval(ft, predictPoint);

	ax = gca;
	ax.YColor = greenColor;
	ax.XColor = greenColor;
	set(gca, 'FontSize', 18);
	hold on;
	ylim([0 80]);
	xlim([20 140]);
	plot(polyval(ft, [0:140]), 'Color', greenColor, 'LineWidth', 3);
	scatter(x, y, 300, '.k');
	line([predictPoint predictPoint], [0 fillPoint], 'Color', yellowColor, 'LineStyle', '--', 'LineWidth', 2);
	line([0 predictPoint], [fillPoint fillPoint], 'Color', yellowColor, 'LineWidth', 2);
	ylabel('Refractoriness at 2.5ms (%)', 'Color', greenColor);
	xlabel('Refractoriness at 2ms (%)', 'Color', greenColor);
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
