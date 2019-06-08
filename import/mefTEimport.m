% mefTEimport imports TE from the provided MEF file, only loading the provided participants, in order.
function [delays, values] = mefTEimport(filepath, participants)
	% Import the raw data
	try
		[~, ~, raw] = xlsread(filepath, 'TE');
	catch ex
		delays = struct();
		values = struct();
		return
	end

	X = getColumns(raw, participants);
	extractedParticipants = string(X(1, 2:size(X, 2)));
	if 0 ~= sum(~strcmp(extractedParticipants', participants))
		disp('WARNING: Participants were not loaded correctly');
	end

	lastParticipant = size(X, 2);

	startInd = 0;
	delay = [0; cell2mat(X(2:end, 1))];
	numTE = 1;
	delays = struct();
	values = struct();

	% Remove delay from X
	X = X(:, 2:end);

	for i=2:length(delay)
		if startInd == 0
			if ~isnan(delay(i))
				startInd = i;
			end
		else
			if isnan(delay(i))
				[delays, values] = loadOneTE(delays, values, delay, X, startInd, i-1);
				startInd = 0;
			end
		end
	end

	if startInd ~= 0
		[delays, values] = loadOneTE(delays, values, delay, X, startInd, length(delay));
	end
end

function [delays, values] = loadOneTE(delays, values, delay, X, startInd, endInd)
	vals = cell2mat(X(startInd:endInd, :));
	name = nameForTE(vals);
	delays.(name) = delay(startInd:endInd, :);
	values.(name) = vals;
end

function [X] = getColumns(raw, participants)
	header = string(raw(1, :));

	X = raw(:, 1);
	for j = 1:length(participants)
		ind = find(strcmp(header, participants(j)));
		if ind
			X = [X raw(:, ind)];
		end
	end
end

function name = nameForTE(vals)
	if vals(2, 1) == 0
		firstVal = nanmean(nanmean(vals(3:4, :)));
	else
		firstVal = nanmean(nanmean(vals(2:3, :)));
	end

	if firstVal > 30 && firstVal < 55
		name = "h40";
	elseif firstVal > 10 && firstVal < 30
		name = "h20";
	elseif firstVal < -30 && firstVal > -55
		name = "d40";
	elseif firstVal < -10 && firstVal > -30
		name = "d20";
	elseif firstVal < -55 && firstVal > -85
		name = "d70";
	elseif firstVal < -85 && firstVal > -120
		name = "d100";
	else
		warning("Invalid values");
		disp(firstVal);
		disp(vals);
	end
end
