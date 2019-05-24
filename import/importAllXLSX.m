% importAllXLSX imports all Excel files at the given path.
function [values, participants, measures] = importAllXLSX(nanMethod, folderpath, expectedNames)
	if nargin < 3
		expectedNames = canonicalNamesNoTE20();
	end
	missingPath = fullfile(fileparts(which(mfilename)),'../missing');
	addpath(missingPath);

	[values, participants, measures] = loadXLSXInDirectory(struct(), struct(), nanMethod, folderpath, '', expectedNames);

	rmpath(missingPath);
end

function [values, participants, measures] = loadXLSXInDirectory(values, participants, nanMethod, folderpath, nameprefix, expectedNames)
	measures = [];

	files = dir(folderpath);
	files = files(~ismember({files.name}, {'.','..'}));  % Remove . and ..
	for file = files'
		[~,name,ext] = fileparts(file.name);
		fullPath = [folderpath '/' file.name];

		if file.isdir
			% Recurse
			[values, participants, measures] = loadXLSXInDirectory(values, participants, nanMethod, fullPath, [nameprefix name '_']);
		elseif ~strcmp(ext, '.xlsx') || startsWith(name, '~$')
			% Ignore files that are not Excel. Also ignore Excel backup files.
			continue
		else
			[thisValues, thisParticipants, thisMeasures] = mefimport(fullPath, false, false, expectedNames);
			thisValues = fillWithMethod(thisValues, nanMethod, true);

			if measuresDiffer(measures, thisMeasures);
				warning(['Could not load ' fullPath])
				continue
			end
			measures = thisMeasures;

			values.(matlab.lang.makeValidName([nameprefix name])) = thisValues;
			participants.(matlab.lang.makeValidName([nameprefix name])) = thisParticipants;
		end
	end
end

function [differ] = measuresDiffer(measures, thisMeasures)
	differ = ~isequal(measures, []) && ~isequal(measures, thisMeasures);
end
