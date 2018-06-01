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

	values = struct();
	participants = struct();

	files = dir([folderpath '/*.xlsx']);
	for file = files'
		[~,name,~] = fileparts(file.name);

		[thisValues, thisParticipants, thisMeasures] = mefimport([folderpath '/' file.name], false);

		if ~exist('measures')
			measures = thisMeasures;
		elseif ~isequal(measures, thisMeasures)
			disp('WARNING: unequal measures');
			disp(measures);
			disp(thisMeasures);
		end

		thisValues = fillWithMethod(thisValues, nanMethod);
		values = setfield(values, name, thisValues);
		participants = setfield(participants, name, thisParticipants);
	end

	rmpath import;
	rmpath missing;
end
