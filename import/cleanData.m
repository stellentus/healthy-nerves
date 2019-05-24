function [values, participants, num] = cleanData(values, participants, nanMethod)
	[values, participants] = deleteNoSex(values, participants);
	[values, participants] = deduplicate(values, participants);
	if nargin >= 3
		addpath ./missing;
		values = fillWithMethod(values, nanMethod, true);
		rmpath ./missing;
	end
	canNum = size(values, 1);
end
