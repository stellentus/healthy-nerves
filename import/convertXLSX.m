% convertXLSX imports the Excel file at the given path and outputs it as MEM files
function convertXLSX(filepath)
	[exVars, participants, measureNames, ~, age, sex, temperature, varNums] = mefimport(filepath, false, false);
	[srPercent, srVal, maxCmaps] = mefSRimport(filepath, participants);
	[cdDuration, cdThreshold] = mefCDimport(filepath, participants);
	[teDelays, teValues] = mefTEimport(filepath, participants);
	[rcDelay, rcVal] = mefRCimport(filepath, participants);
	[ivCurrent, ivThreshold] = mefIVimport(filepath, participants);

	[dirpath, fileName] = fileparts(filepath);
	[~,~] = mkdir(strcat(dirpath, "/convMEM")); % Read and ignore returns to suppress warning if dir exists.

	for pIdx = 1:length(participants)
		fileID = fopen(strcat(dirpath, "/convMEM/", participants(pIdx), ".MEM"),'w');

		writeHeader(fileID, filepath, participants(pIdx,:), age(:,pIdx), sex(:,pIdx), temperature(:,pIdx));
		writeSR(fileID, maxCmaps(:,pIdx), srPercent, srVal(:,pIdx));
		writeCD(fileID, cdDuration, cdThreshold(:,pIdx));
		writeTE(fileID, teDelays, teValues, pIdx);
		writeRC(fileID, rcDelay, rcVal(:,pIdx));
		writeIV(fileID, ivCurrent, ivThreshold(:,pIdx));
		writeExVars(fileID, measureNames, exVars(pIdx,:), varNums);

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
	if length(srPercent) == 0
		return
	end

	fprintf(fileID, "\n STIMULUS-RESPONSE DATA\n\n");
	fprintf(fileID, "Values are from Excel\n\n");
	fprintf(fileID, " Max CMAP  1 ms =  %f mV\n\n", maxCmap);
	fprintf(fileID, "                     	%% Max               	Stimulus\n");

	for i=1:length(srPercent)
		fprintf(fileID, "SR.%d                	 %d                  	 %f\n", i, srPercent(i), srVal(i));
	end
	fprintf(fileID, "\n");
end

function writeCD(fileID, cdDuration, cdThreshold)
	if length(cdDuration) == 0
		return
	end

	fprintf(fileID, "\n   CHARGE DURATION DATA\n\n");
	fprintf(fileID, "                     	Duration (ms)       	 Threshold (mA)     	  Threshold charge (mA.mS)\n");

	for i=1:length(cdDuration)
		fprintf(fileID, " QT.%d                	 %.1f                 	 %f           	 %f\n", i, cdDuration(i), cdThreshold(i), cdDuration(i)*cdThreshold(i));
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
	if length(rcDelay) == 0
		return
	end

	fprintf(fileID, "\n   RECOVERY CYCLE DATA\n\n");
	fprintf(fileID, "                     	Interval (ms)       	  Threshold change (%%)\n");

	for i=1:length(rcDelay)
		fprintf(fileID, "RC1.%d               	 %f                	%f\n", i, rcDelay(i), rcVal(i));
	end
	fprintf(fileID, "\n");
end

function writeIV(fileID, ivCurrent, ivThreshold)
	if length(ivCurrent) == 0
		return
	end

	fprintf(fileID, "\n  THRESHOLD I/V DATA\n\n");
	fprintf(fileID, "                    	Current (%%)         	  Threshold redn. (%%)\n");

	for i=1:length(ivCurrent)
		fprintf(fileID, "IV1.%d               	 %d                 	%f\n", i, ivCurrent(i), ivThreshold(i));
	end
	fprintf(fileID, "\n");
end

function writeExVars(fileID, names, exVars, varNums)
	if length(names) == 0
		return
	end

	fprintf(fileID, "\n  DERIVED EXCITABILITY VARIABLES\n\n");
	fprintf(fileID, "Program = QTrac Unknown (from Excel)\n\n");

	hasExtra = false;
	for i=1:length(names)
		if isnan(exVars(i))
			continue;
		end
		if varNums(i) <= 35
			fprintf(fileID, " %d.                 	%f               	%s\n", varNums(i), exVars(i), names(i));
		else
			hasExtra = true;
		end
	end
	fprintf(fileID, "\n");

	if hasExtra
		fprintf(fileID, "  EXTRA VARIABLES (add here as required, e.g. Potassium = 4.5)\n\n");
		for i=1:length(names)
			if isnan(exVars(i))
				continue;
			end
			if varNums(i) > 35
				fprintf(fileID, "%s = %f\n", names(i), exVars(i));
			end
		end
		fprintf(fileID, "\n");
	end
end

function cur = teCurForDelay(delay, current)
	if delay >= 10 && delay <= 109
		cur = current;
	else
		cur = 0;
	end
end
