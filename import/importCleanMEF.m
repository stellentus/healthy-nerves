function [values, participants, num, measures] = importCleanMEF(filepath, expectedNames, nanMethod)
	[~,~,ext] = fileparts(filepath);
	if strcmp(ext, 'xlsx')
		[values, participants, measures] = mefimport(filepath, false, false, expectedNames);
	else
		[values, participants, measures] = importAllXLSX('none', filepath, expectedNames);
		[values, participants] = flattenStructs(values, participants);
	end

	[values, participants, num] = cleanData(values, participants, nanMethod);
end
