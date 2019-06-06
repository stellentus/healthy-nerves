% convertXLSX imports the Excel file at the given path and outputs it as MEM files
function convertXLSX(filepath)
	[data, participants, measureNames, ~, age, sex, temperature] = mefimport(filepath);

	dirpath = fileparts(filepath);
	[~,~] = mkdir(strcat(dirpath, "/convMEM")); % Read and ignore returns to suppress warning if dir exists.

	for i = 1:length(participants)
		writeParticipant(filepath, participants(i), age(i), sex(i), temperature(i));
	end
end

function writeParticipant(excelPath, participantName, age, sex, temperature)
	[dirpath, fileName] = fileparts(excelPath);
	fileID = fopen(strcat(dirpath, "/convMEM/", participantName, ".MEM"),'w');

	if sex == 1
		sex = "M";
	else
		sex = "F";
	end
	writeHeader(fileID, excelPath, participantName, age, sex, temperature);

	fclose(fileID);
end

function writeHeader(fileID, filepath, name, age, sex, temperature)
	fprintf(fileID, " File:              	%s\n", filepath);
	fprintf(fileID, " Name:              	%s\n", name);
	fprintf(fileID, " Protocol:          	\n"); % TODO figure this out
	fprintf(fileID, " Date:              	\n");
	fprintf(fileID, " Start time:        	\n");
	fprintf(fileID, " Age:               	%d\n", age);
	fprintf(fileID, " Sex:               	%s\n", sex);
	fprintf(fileID, " Temperature:       	%.1f\n", temperature);
	fprintf(fileID, " S/R sites:         	median\n");
	fprintf(fileID, " NC/disease:        	\n");
	fprintf(fileID, " Operator:          	\n");
	fprintf(fileID, " Comments:          	this MEM file was created from an Excel file\n");
end
