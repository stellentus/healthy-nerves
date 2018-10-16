% importExcel imports data from the files
function [values, participants, measures] = importTwo(cPath, mPath, shouldDeleteNaN)
	if nargin == 2
		shouldDeleteNaN = false;
	end

	% Import the data from MEF
	[cData, cParticipantNames, cMeasureNames, cStats] = mefimport(cPath);
	[mData, mParticipantNames, mMeasureNames, mStats] = mefimport(mPath);

	% Verify participant names are the same; then only save one list
	indices = verifyNames(cParticipantNames, mParticipantNames);
	[participants, cData, mData] = deleteRows(indices, cParticipantNames, cData, mData);
	clear cParticipantNames mParticipantNames indices;

	% Verify measure names are the same; then only save one list
	indices = verifyNames(cMeasureNames, mMeasureNames);
	[measures, cData, mData] = deleteColumns(indices, cMeasureNames, cData, mData);
	clear cMeasureNames mMeasureNames indices;

	if shouldDeleteNaN
		[participants, cData, mData] = deleteNaN(participants, cData, mData);
	end

	% Calculate unique columns (e.g. not age and sex)
	unique = [];
	for i = 1:length(measures)
		if ~isequal(cData(:,i), mData(:,i))
			unique = [unique, i];
		end
	end

	[values, measures] = combineDatasets(measures, cData, 'Leg', mData, 'Arm', unique);
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
