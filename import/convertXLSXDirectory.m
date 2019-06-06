% convertXLSXDirectory imports all Excel files at the given path and outputs them as MEM files
function convertXLSXDirectory(folderpath)
	convertXLSXInDirectory(folderpath);
end

function convertXLSXInDirectory(folderpath)
	files = dir(folderpath);
	files = files(~ismember({files.name}, {'.','..'}));  % Remove . and ..
	for file = files'
		[~,name,ext] = fileparts(file.name);
		fullPath = [folderpath '/' file.name];

		if file.isdir
			% Recurse
			convertXLSXInDirectory(fullPath);
		elseif ~strcmp(ext, '.xlsx') || startsWith(name, '~$')
			% Ignore files that are not Excel. Also ignore Excel backup files.
			continue
		else
			convertXLSX(fullPath);
		end
	end
end
