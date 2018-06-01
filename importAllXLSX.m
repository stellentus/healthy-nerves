% importAllXLSX imports all Excel files at the given path.
function [values, participants, measures] = importAllXLSX(nanMethod, folderpath)
	if nargin < 2
		folderpath = 'data';
		if nargin < 1
			nanMethod = 'Mean';
		end
	end

	addpath missing;
	addpath import;

	[values, participants, measures] = loadXLSXInDirectory(nanMethod, folderpath);

	rmpath import;
	rmpath missing;
end

function [values, participants, measures] = loadXLSXInDirectory(nanMethod, folderpath)
	values = struct();
	participants = struct();
	measures = [];

	files = dir(folderpath);
	for file = files'
		[~,name,ext] = fileparts(file.name);
		if ~strcmp(ext, '.xlsx')
			continue
		end

		[thisValues, thisParticipants, thisMeasures] = mefimport([folderpath '/' file.name], false);

		measures = warnIfMeasuresDiffer(measures, thisMeasures);

		thisValues = fillWithMethod(thisValues, nanMethod);
		values = setfield(values, name, thisValues);
		participants = setfield(participants, name, thisParticipants);
	end
end

function [thisMeasures] = warnIfMeasuresDiffer(measures, thisMeasures)
	if ~isequal(measures, []) && ~isequal(measures, thisMeasures)
		disp('WARNING: unequal measures');
		disp(measures);
		disp(thisMeasures);
	end
end
