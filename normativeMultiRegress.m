%% normativeMultiRegress: Calculate sex/age/temperature regression in normative data.
function normativeMultiRegress(values)
	if nargin == 0
		load("bin/batch-normative.mat");
		values = [canValues; japValues; porValues];
	end

	sexColumn = values(:,15);
	ageColumn = values(:,14);
	tempColumn = values(:,8);
	astCols = [ageColumn sexColumn tempColumn];

	males = values(sexColumn == 1, :);
	females = values(sexColumn == 2, :);
	if size(males, 1) + size(females, 1) ~= size(values, 1)
		error("Could not split males and females")
	end
	[isLinM, isLogM] = normativeDistributions(males, measures);
	[isLinF, isLogF] = normativeDistributions(females, measures);
	clear males, females;


	if nargout == 0
		fprintf(" Measure Name        & Distribution & Age Coeff (r^2) & Sex Coeff (r^2) & Temp Coeff (r^2)\n");
		fprintf("-------------------- & ------------ & --------------- & --------------- & ---------------\n");
	end

	threshold = 0.05;

	measures = altNames();
	insigMeasures = [];
	inds = altInds();
	rsqs = zeros(length(measures), 3);
	for i=inds
		thisMeas = measures(1);
		measures = measures(2:end);

		thisCol = values(:, i);
		% It might be both linear and log, in which case we use linear, not this if statement.
		isLog = ~(isLinM(i) && isLinF(i)) && isLogM(i) && isLogF(i);
		if isLog
			thisCol = log(abs(thisCol));
		end

		thisCol = thisCol./mean(thisCol); % Divide by feature mean, so the results are relative coefficients.

		[str, rsq] = stepWiseString(thisMeas, astCols, thisCol, threshold, isLog);
		rsqs(i,:) = rsq;
		if strlength(str) == 0
			insigMeasures = [insigMeasures, thisMeas];
		else
			disp(str);
		end
	end

	plotBarR2('barr2-5', rsqs, altInds(), altNames(), threshold);
	plotBarR2('barr2-0', rsqs, altInds(), altNames(), 0);

	fprintf("\nInsignificant measures:\n")
	fprintf("\t%s\n", insigMeasures);
end

function [str] = dispCoeff(coeff, pval, rsq, threshold, ind)
	% Factors below the variance threshold aren't worth considering.
	if rsq(ind) < threshold
		str = "      ---      ";
		return;
	end

	coeff = coeff(ind);
	pval = pval(ind);
	rsq = rsq(ind);

	coPre = " ";
	if coeff < 0
		coPre = "-";
		coeff = -coeff;
	end
	coeff = coeff * 100; % Display as a percent change

	if coeff > 10
		coeffStr = coPre + "%2.1f";
	elseif coeff < 0.01
		coeffStr = coPre + "%1.3f";
	else
		coeffStr = coPre + "%1.2f";
	end

	parens = sprintf("(%.0f%%)", rsq*100);
	str = sprintf(coeffStr + " %4s", coeff, parens);
end

function [str] = altNames()
	str = ["Latency","Max CMAP","Stim at 50\%","SR slope","Rheobase","SDTC","TEd (90--100ms)","TEh (90--100ms)","TEd peak","TEd undershoot","Accom half-time","TEh(10--20ms)","TEh overshoot","TEh(20--40ms)","TEd(10--20ms)","TEd (40--60ms)","TEh(slope, 140ms)","S2 accom.","Hyper. I/V slope","Min. I/V slope","Resting I/V slope","Superexcitable","Late subexcitable","Refractoriness 2.5","RRP","Refractoriness 2","Superex. at 5 ms","Superex. at 7 ms"];
end

function [ids] = altInds()
	ids = [16,5,1,4,3,2,18,10,22,20,24,19,21,27,11,17,28,23,25,7,6,12,13,26,9,29,31,30];
end

function [str, rsq] = stepWiseString(thisMeas, astCols, thisCol, threshold, isLog)
	[b, ~, modelp, inmodel, ~, ~, history] = stepwisefit(astCols, thisCol, 'penter', 0.05, 'premove', 0.1, 'display', 'off');

	% Calculate r^2.
	n = length(thisCol);
	adjrsq = 1 - history.rmse.^2/var(thisCol);
	adjrsq = adjrsq - [0, adjrsq(1:end-1)]; % We want each value as the marginal increase past the previous variable addition.
	clear rsq n;

	% Figure out which index changed for each r^2. This code only works if no index is ever removed.
	shiftHistory = history.in - [0 0 0; history.in(1:end-1,:)]; % history.in contains all indices at each point, but we just want the diff
	[iR,iC]=find(shiftHistory); % Based on this diff, get the list of indices as they were added
	sr = sortrows([iR,iC]);     % But now we need to sort it.
	rsq = zeros(1,3);
	rsq(sr(:,2)) = adjrsq;      % Finally, access based on these values.
	clear shiftHistory iR iC sr;

	% If none of the factors contain at least 5% variance, ignore them.
	if sum(sum(rsq >= threshold)) == 0
		str = "";
		return
	end

	strAge = dispCoeff(b, modelp, rsq, threshold, 1);
	strSex = dispCoeff(b, modelp, rsq, threshold, 2);
	strTemp = dispCoeff(b, modelp, rsq, threshold, 3);

	logStr = "linear";
	if isLog
		logStr = "logarithmic";
	end

	str = sprintf("%20s & %12s & %15s & %15s & %15s", thisMeas, logStr, strAge, strSex, strTemp);
end

function plotBarR2(filename, rsqs, inds, measures, threshold)
	rsqs = rsqs(inds, [3,1,2]); % Put in order temperature, age, sex. Only keep desired indicies.

	rsqs(rsqs<threshold) = 0;

	[rsqs, ind] = sortrows(rsqs, 3, 'descend'); % Sort sex
	measures = measures(ind);
	[rsqs, ind] = sortrows(rsqs, 2, 'descend'); % Sort age
	measures = measures(ind);
	[rsqs, ind] = sortrows(rsqs, 1, 'descend'); % Sort temperature
	measures = measures(ind);

	sums = sum(rsqs, 2);
	measures = measures(sums>0);
	rsqs = rsqs(sums>0,:);

	[~,~] = mkdir('img/stats'); % Read and ignore returns to suppress warning if dir exists.
	pathstr = sprintf('img/stats/%s-%02d-%02d-%02d-%02d-%02d-%02.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	bar(rsqs, 'stacked');
	titleStrings = {"Contribution of Temperature, Age, and Sex to","Variance in Excitability Variables"};
	if threshold > 0
		titleStrings{end+1} = sprintf('(minimum %d%% variance)', threshold*100);
	end
	title(titleStrings);
	ylabel("r^2 (%)");
	legend({'Temperature', 'Age', 'Sex'});

	xtickangle(45);
	set(gca,'xtick',1:length(measures));
	set(gca, 'xticklabel', measures);

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/stats/', filename, '.png')); % Also save without timestamp
end
