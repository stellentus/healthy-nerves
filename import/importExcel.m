% importExcel imports data from the files
function [participants, measures, data1, data2, uniqueColumns] = importExcel(path1, path2)
	if nargin == 2
		[data1, data2, participants, measures, uniqueColumns] = importTwo(path1, path2);
	else
		[data1, measures, participants] = mefimport(path1);
		uniqueColumns = [];
		data2 = [];
	end
end

function [cData, mData, participants, measures, unique] = importTwo(cPath, mPath)
	% Import the data from MEF
	[cData, cMeasureNames, cParticipantNames, cStats] = mefimport(cPath);
	[mData, mMeasureNames, mParticipantNames, mStats] = mefimport(mPath);

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
		if i == 14
			continue; % Temporary fix because age is unique due to some odd data
		end
		if ~isequal(cData(:,i), mData(:,i))
			unique = [unique, i];
		end
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