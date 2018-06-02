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
	files = files(~ismember({files.name}, {'.','..'}));  % Remove . and ..
	for file = files'
		[~,name,ext] = fileparts(file.name);
		fullPath = [folderpath '/' file.name];

		if isfolder(fullPath)
			% Recurse
			[thisValues, thisParticipants, thisMeasures] = loadXLSXInDirectory(nanMethod, fullPath);
			if isempty(fieldnames(thisValues))
				% We found nothing in the folder, so don't add it
				continue
			end
		elseif ~strcmp(ext, '.xlsx')
			continue
		else
			[thisValues, thisParticipants, thisMeasures] = mefimport(fullPath, false, false);
			try
				thisValues = fillWithMethod(thisValues, nanMethod);
			catch
				% It probably failed because the filling method was too complicated, so default to 0 which should always work.
				thisValues = fillWithMethod(thisValues, 'Zero');
			end
		end

		try
			measures = warnIfMeasuresDiffer(measures, thisMeasures);
		catch
			warning(['Could not load ' fullPath])
			continue
		end
		values = setfield(values, matlab.lang.makeValidName(name), thisValues);
		participants = setfield(participants, matlab.lang.makeValidName(name), thisParticipants);
	end
end

function [thisMeasures] = warnIfMeasuresDiffer(measures, thisMeasures)
	if ~isequal(measures, []) && ~isequal(measures, thisMeasures)
		error('WARNING: unequal measures');
	end
end
