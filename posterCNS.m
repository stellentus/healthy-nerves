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

	x = cData(:, 26);
	y = cData(:, 29);
	ft = polyfit(x, y, 1);
	fillPoint = polyval(ft, 38);

	hold on;
	xlim([0 80]);
	ylim([20 160]);
	plot(polyval(ft, [0:70]), 'Color', [0.03529411764705882353, 0.38039215686274509804, 0.2], 'LineWidth', 3);
	scatter(x, y, 300, '.k');
	line([38 38], [20 fillPoint], 'Color', [1 0.1490196078431372549 0]);
	line([0 38], [fillPoint fillPoint], 'Color', [1 0.1490196078431372549 0],'LineStyle', '--');
	xlabel('Refractoriness at 2.5ms (%)');
	ylabel('Refractoriness at 2ms (%)');

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
