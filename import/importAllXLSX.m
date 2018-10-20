% importAllXLSX imports all Excel files at the given path.
function [values, participants, measures] = importAllXLSX(nanMethod, folderpath)
	missingPath = fullfile(fileparts(which(mfilename)),'../missing');
	addpath(missingPath);

	[values, participants, measures] = loadXLSXInDirectory(struct(), struct(), nanMethod, folderpath, '');

	rmpath(missingPath);
end

function [values, participants, measures] = loadXLSXInDirectory(values, participants, nanMethod, folderpath, nameprefix)
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
			[thisValues, thisParticipants, thisMeasures] = mefimport(fullPath, false, false, canonicalNamesNoTE20());
			filled = false;
			try
				thisValues = fillWithMethod(thisValues, nanMethod);
				if sum(sum(isnan(thisValues))) == 0
					filled = true;
				end
			catch
			end

			if ~filled
				% It probably failed because the filling method was too complicated, so default to 0 which should always work.
				thisValues = fillWithMethod(thisValues, 'Zero');
			end

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
