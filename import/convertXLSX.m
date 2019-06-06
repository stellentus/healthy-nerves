% convertXLSX imports the Excel file at the given path and outputs it as MEM files
function convertXLSX(filepath)
	[exInds, participants, measureNames, ~, age, sex, temperature] = mefimport(filepath, false, false);
	[srPercent, srVal, maxCmaps] = mefSRimport(filepath, participants);
	[teDelays, teValues] = mefTEimport(filepath, participants);
	[rcDelay, rcVal] = mefRCimport(filepath, participants);

	[dirpath, fileName] = fileparts(filepath);
	[~,~] = mkdir(strcat(dirpath, "/convMEM")); % Read and ignore returns to suppress warning if dir exists.

	for pIdx = 1:length(participants)
		fileID = fopen(strcat(dirpath, "/convMEM/", participants(pIdx), ".MEM"),'w');

		writeHeader(fileID, filepath, participants(pIdx,:), age(:,pIdx), sex(:,pIdx), temperature(:,pIdx));
		writeSR(fileID, maxCmaps(:,pIdx), srPercent, srVal(:,pIdx));
		writeTE(fileID, teDelays, teValues, pIdx);
		writeRC(fileID, rcDelay, rcVal(:,pIdx));

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

function writeSR(fileID, maxCmap, srPercent, srVal)
	fprintf(fileID, "\n STIMULUS-RESPONSE DATA\n\n");
	fprintf(fileID, "Values are from Excel\n\n");
	fprintf(fileID, " Max CMAP  1 ms =  %f mV\n\n", maxCmap);
	fprintf(fileID, "                     	%% Max               	Stimulus\n");

	for i=1:length(srPercent)
		fprintf(fileID, "SR.%d                	 %d                  	 %f\n", i, srPercent(i), srVal(i));
	end
	fprintf(fileID, "\n");
end

function writeTE(fileID, teDelays, teValues, pIdx)
	fprintf(fileID, "\n   THRESHOLD ELECTROTONUS DATA\n\n");
	fprintf(fileID, "                     	Delay (ms)          	Current (%%)         	Thresh redn. (%%)\n");

	if isfield(teDelays, 'h40')
		fprintf(fileID, "\n");
		for i=1:length(teDelays.h40)
			fprintf(fileID, "TE1.%d               	 %d                  	%d                   	%f\n", i, teDelays.h40(i), teCurForDelay(teDelays.h40(i), 40), teValues.h40(i, pIdx));
		end
	end
	if isfield(teDelays, 'd40')
		fprintf(fileID, "\n");
		for i=1:length(teDelays.d40)
			fprintf(fileID, "TE2.%d               	 %d                  	%d                   	%f\n", i, teDelays.d40(i), teCurForDelay(teDelays.d40(i), -40), teValues.d40(i, pIdx));
		end
	end
	if isfield(teDelays, 'h20')
		fprintf(fileID, "\n");
		for i=1:length(teDelays.h20)
			fprintf(fileID, "TE3.%d               	 %d                  	%d                   	%f\n", i, teDelays.h20(i), teCurForDelay(teDelays.h20(i), 20), teValues.h20(i, pIdx));
		end
	end
	if isfield(teDelays, 'd20')
		fprintf(fileID, "\n");
		for i=1:length(teDelays.d20)
			fprintf(fileID, "TE4.%d               	 %d                  	%d                   	%f\n", i, teDelays.d20(i), teCurForDelay(teDelays.d20(i), -20), teValues.d20(i, pIdx));
		end
	end

	fprintf(fileID, "\n");
end

function writeRC(fileID, rcDelay, rcVal)
	fprintf(fileID, "\n   RECOVERY CYCLE DATA\n\n");
	fprintf(fileID, "                     	Interval (ms)       	  Threshold change (%%)\n");

	for i=1:length(rcDelay)
		fprintf(fileID, "RC1.%d               	 %f                	%f\n", i, rcDelay(i), rcVal(i));
	end
	fprintf(fileID, "\n");
end

function cur = teCurForDelay(delay, current)
	if delay >= 10 && delay <= 109
		cur = current;
	else
		cur = 0;
	end
end
