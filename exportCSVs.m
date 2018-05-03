% exportCSVs loads all available MEF and exports them as CSV
function exportCSVs()

	addpath import;

	files = dir('data/*.xlsx');
	for file = files'
		disp(['Writing ' file.name '...']);
		[~, name, ext] = fileparts(file.name);
		[values, participants, measures] = mefimport(['data/' name ext]);

		% Get rid of any commas
		measures = strrep(measures, ',', ';');
		participants = strrep(participants, ',', ';');

		outputpath = ['data/csv/' name '.csv'];
		fileID = fopen(outputpath, 'w');

		% Print header row
		fprintf(fileID, 'Participant');
		fprintf(fileID, ',%s', measures);
		fprintf(fileID, '\n');

		for i = 1:length(participants)
			fprintf(fileID, '%s', participants(i));
			fprintf(fileID, ',%f', values(i, :));
			fprintf(fileID, '\n');
		end
	end

	rmpath import;
end
