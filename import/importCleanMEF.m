function [values, participants, num, measures] = importCleanMEF(filepath, expectedNames, nanMethod)
	[~,~,ext] = fileparts(filepath);
	if strcmp(ext, '.xlsx')
		[values, participants, measures] = mefimport(filepath, false, false, expectedNames);
	else
		[values, participants, measures] = importAllXLSX('none', filepath, expectedNames);
		[values, participants] = flattenStructs(values, participants);
	end

	[values, participants, num] = cleanData(values, participants, nanMethod, expectedNames);
end

function [flatVals, flatParts] = flattenStructs(structVals, structParts)
	flatVals = [];
	flatParts = [];
	fields = fieldnames(structVals);
	for i = 1:numel(fields)
		thisParts = structParts.(fields{i});
		thisVals = structVals.(fields{i});
		for j = 1:length(thisParts)
			% Only add the data if the participant hasn't already been added
			if length(flatParts) < 2 || sum(ismember(flatParts, thisParts(j))) == 0
				flatVals = [flatVals; thisVals(j, :)];
				flatParts = [flatParts; thisParts(j)];
			end
		end
	end
end
