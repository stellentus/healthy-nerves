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

	[values, participants, measures] = loadXLSXInDirectory(struct(), struct(), nanMethod, folderpath, '');

	rmpath import;
	rmpath missing;
end

function [values, participants, measures] = loadXLSXInDirectory(values, participants, nanMethod, folderpath, nameprefix)
	measures = [];

	files = dir(folderpath);
	files = files(~ismember({files.name}, {'.','..'}));  % Remove . and ..
	for file = files'
		[~,name,ext] = fileparts(file.name);
		fullPath = [folderpath '/' file.name];

		if isfolder(fullPath)
			% Recurse
			[values, participants, measures] = loadXLSXInDirectory(values, participants, nanMethod, fullPath, [nameprefix name '_']);
		elseif ~strcmp(ext, '.xlsx') || startsWith(name, '~$')
			% Ignore files that are not Excel. Also ignore Excel backup files.
			continue
		else
			[thisValues, thisParticipants, thisMeasures] = mefimport(fullPath, false, false);
			try
				thisValues = fillWithMethod(thisValues, nanMethod);
			catch
				% It probably failed because the filling method was too complicated, so default to 0 which should always work.
				thisValues = fillWithMethod(thisValues, 'Zero');
			end

			if measuresDiffer(measures, thisMeasures);
				warning(['Could not load ' fullPath])
				continue
			end

			values = setfield(values, matlab.lang.makeValidName([nameprefix name]), thisValues);
			participants = setfield(participants, matlab.lang.makeValidName([nameprefix name]), thisParticipants);
		end
	end
end

function [differ] = measuresDiffer(measures, thisMeasures)
	differ = ~isequal(measures, []) && ~isequal(measures, thisMeasures);
end
