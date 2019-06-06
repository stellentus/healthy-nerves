% convertXLSX imports the Excel file at the given path and outputs it as MEM files
function convertXLSX(filepath)
	[data, participants, measureNames, ~, age, sex, temperature] = mefimport(filepath);
	[rcDelay, rcVal] = mefRCimport(filepath, participants);

	[dirpath, fileName] = fileparts(filepath);
	[~,~] = mkdir(strcat(dirpath, "/convMEM")); % Read and ignore returns to suppress warning if dir exists.

	for i = 1:length(participants)
		fileID = fopen(strcat(dirpath, "/convMEM/", participants(i), ".MEM"),'w');

		writeHeader(fileID, filepath, participants(i), age(i), sex(i), temperature(i));
		writeRC(fileID, rcDelay, rcVal);

		fclose(fileID);
	end
end

function writeHeader(fileID, filepath, name, age, sex, temperature)
	if sex == 1
		sex = "M";
	else
		sex = "F";
	end

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
	fprintf(fileID, "\n");
end

function writeRC(fileID, rcDelay, rcVal)
	fprintf(fileID, "   RECOVERY CYCLE DATA\n\n");
	fprintf(fileID, "                     	Interval (ms)       	  Threshold change (%%)\n");

	for i=1:length(rcDelay)
		fprintf(fileID, "RC1.%d               	 %f                	%f\n", i, rcDelay(i), rcVal(i));
	end
	fprintf(fileID, "\n");
end
