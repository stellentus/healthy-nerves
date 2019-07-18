%% normativeMultiRegress: Calculate sex/age/temperature regression in normative data.
function normativeMultiRegress(shouldNormalize, values, filenameSuffix, titleString)
	if nargin < 1
		shouldNormalize = true;
	end
	if nargin < 2
		load("bin/batch-normative.mat");
		values = [canValues; japValues; porValues];
	end
	if nargin < 3
		filenameSuffix = '';
	end
	if nargin < 4
		titleString = "";
	end

	sexColumn = values(:,15);
	ageColumn = values(:,14);
	tempColumn = values(:,8);
	astCols = [ageColumn sexColumn tempColumn];

	if nargout == 0
		if ~shouldNormalize
			fprintf(" Measure Name        & Age Coeff (r^2) & Temp Coeff (r^2)& Sex Coeff (r^2)  & Intercept\n");
			fprintf("-------------------- & --------------- & --------------- & ---------------- & ---------\n");
		else
			fprintf(" Measure Name        & Age Coeff (r^2) & Temp Coeff (r^2) & Sex Coeff (r^2)\n");
			fprintf("-------------------- & --------------- & --------------- & ---------------\n");
		end
	end

	if shouldNormalize
		threshold = 0.05;
	else
		threshold = 0;
	end

	measures = altNames();
	insigMeasures = [];
	inds = altInds();
	rsqs = zeros(length(measures), 3);
	for i=inds
		thisMeas = measures(1);
		measures = measures(2:end);

		[str, rsq] = stepWiseString(thisMeas, astCols, values(:, i), threshold, shouldNormalize);
		rsqs(i,:) = rsq;
		if strlength(str) == 0
			insigMeasures = [insigMeasures, thisMeas];
		else
			disp(str);
		end
	end

	plotBarR2(strcat('barr2-5', filenameSuffix), rsqs, altInds(), altNames(), threshold, titleString);
	plotBarR2(strcat('barr2-0', filenameSuffix), rsqs, altInds(), altNames(), 0, titleString);

	fprintf("\nInsignificant measures:\n")
	fprintf("\t%s\n", insigMeasures);
end

function [str] = dispCoeff(coeff, pval, rsq, threshold, ind, shouldNormalize)
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
	if shouldNormalize
		coeff = coeff * 100; % Display as a percent change
	end

	if coeff > 10
		coeffStr = coPre + "%2.1f";
	elseif coeff < 0.01
		coeffStr = coPre + "%1.5f";
	elseif coeff < 1
		coeffStr = coPre + "%1.3f";
	else
		coeffStr = coPre + "%1.2f";
	end

	if shouldNormalize
		parens = sprintf("(%.0f\\%%)", rsq*100);
	elseif pval < 0.05
		parens = sprintf("(r^2=%.0f\\%%)", rsq*100);
	else
		parens = sprintf("(p=%.2f)", pval);
	end

	str = sprintf(coeffStr, coeff);
	str = sprintf("%s %4s", str, parens);
end

function [str] = altNames()
	str = ["Latency","Max CMAP","Stim at 50\%","SR slope","Rheobase","SDTC","TEd (90--100ms)","TEh (90--100ms)","TEd peak","TEd undershoot","Accom half-time","TEh(10--20ms)","TEh overshoot","TEh(20--40ms)","TEd(10--20ms)","TEd (40--60ms)","TEh(slope, 140ms)","S2 accom.","Hyper. I/V slope","Min. I/V slope","Resting I/V slope","Superexcitable","Late subexcitable","Refractoriness 2.5","RRP","Refractoriness 2","Superex. at 5 ms","Superex. at 7 ms"];
end

function [ids] = altInds()
	ids = [16,5,1,4,3,2,18,10,22,20,24,19,21,27,11,17,28,23,25,7,6,12,13,26,9,29,31,30];
end

function [str, rsq] = stepWiseString(thisMeas, astCols, thisCol, threshold, shouldNormalize)
	if shouldNormalize
		% Divide by feature mean, so the results are relative coefficients.
		thisCol = thisCol./mean(thisCol);
	end

	[b, ~, modelp, ~, stats, ~, history] = stepwisefit(astCols, thisCol, 'penter', 0.05, 'premove', 0.1, 'display', 'off');

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

	strAge = dispCoeff(b, modelp, rsq, threshold, 1, shouldNormalize);
	strSex = dispCoeff(b, modelp, rsq, threshold, 2, shouldNormalize);
	strTemp = dispCoeff(b, modelp, rsq, threshold, 3, shouldNormalize);

	str = sprintf("%20s & %15s & %15s & %15s", thisMeas, strAge, strTemp, strSex);
	if ~shouldNormalize
		str = sprintf("%s  & %.3f", str, stats.intercept);
	end
end

function plotBarR2(filename, rsqs, inds, measures, threshold, titleString)
	disp(filename)
	rsqs = rsqs(inds, [1,3,2]); % Put in order age, temperature, sex. Only keep desired indicies.

	rsqs(rsqs<threshold) = 0;

	% Sort in reverse order
	[rsqs, ind] = sortrows(rsqs, 3, 'descend');
	measures = measures(ind);
	[rsqs, ind] = sortrows(rsqs, 2, 'descend');
	measures = measures(ind);
	[rsqs, ind] = sortrows(rsqs, 1, 'descend');
	measures = measures(ind);

	sums = sum(rsqs, 2);
	measures = measures(sums>0);
	rsqs = rsqs(sums>0,:);

	[~,~] = mkdir('img/stats'); % Read and ignore returns to suppress warning if dir exists.
	pathstr = sprintf('img/stats/%s-%02d-%02d-%02d-%02d-%02d-%02.0f', filename, clock);

	fig = figure('DefaultAxesFontSize', 18, 'Position', [10 10 900 600]);

	bar(rsqs, 'stacked');
	titleStrings = {"Contribution of Age, Temperature, and Sex to","Variance in Excitability Variables",titleString};
	if threshold > 0
		titleStrings{end+1} = sprintf('(minimum %d%% variance)', threshold*100);
	end
	title(titleStrings);
	ylabel("r^2 (%)");
	legend({'Age', 'Temperature', 'Sex'});

	xtickangle(45);
	set(gca,'xtick',1:length(measures));
	set(gca, 'xticklabel', prettyMeasures(measures));

	savefig(fig, strcat(pathstr, '.fig'), 'compact');
	saveas(fig, strcat(pathstr, '.png'));
	copyfile(strcat(pathstr, '.png'), strcat('img/stats/', filename, '.png')); % Also save without timestamp
end

function [measures] = prettyMeasures(measures)
	measures = strrep(measures, '--', char(8211));
	measures = strrep(measures, '\%', '%');
end
