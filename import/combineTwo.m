% combineTwo imports data from the files
function [values, measures] = combineTwo(cData, mData, measures)
	% Calculate unique columns (e.g. not age and sex)
	unique = [];
	for i = 1:length(measures)
		if ~isequal(cData(:,i), mData(:,i))
			unique = [unique, i];
		end
	end

	[values, measures] = combineDatasets(measures, cData, 'Leg', mData, 'Arm', unique);
end
