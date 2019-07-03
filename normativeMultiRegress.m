%% normativeMultiRegress: Calculate sex/age/temperature regression in normative data.
function normativeMultiRegress(values)
	if nargin == 0
		load("bin/batch-normative.mat");
		values = [canValues; japValues; porValues];
	end

	sexIndex = 15;
	males = values(values(:,sexIndex) == 1, :);
	females = values(values(:,sexIndex) == 2, :);
	if size(males, 1) + size(females, 1) ~= size(values, 1)
		error("Could not split males and females")
	end
	[isLinM, isLogM] = normativeDistributions(males, measures);
	[isLinF, isLogF] = normativeDistributions(females, measures);
	clear males, females;

	ageIndex = 8;
	tempIndex = 14;

	astCols = values(:,[sexIndex, ageIndex, tempIndex]);

	if nargout == 0
		fprintf(" Measure Name        & Sex Coeff (p)      & Age Coeff (p)      & Temp Coeff (p)    \n");
		fprintf("-------------------- & ------------------ & ------------------ & ------------------\n");
	end

	measures = altNames();
	insigMeasures = [];
	for i=altInds()
		thisMeas = measures(1);
		measures = measures(2:end);

		thisCol = values(:, i);
		% It might be both linear and log, in which case we use linear, not this if statement.
		if ~(isLinM(i) && isLinF(i)) && isLogM(i) && isLogF(i)
			thisCol = log(abs(thisCol));
		end

		str = stepWiseString(thisMeas, astCols, thisCol);
		if strlength(str) == 0
			insigMeasures = [insigMeasures, thisMeas];
		else
			disp(str);
		end
	end

	fprintf("\nInsignificant measures:\n")
	fprintf("\t%s\n", insigMeasures);
end

function [str] = dispCoeff(coeff, pval, inmodel, ind)
	if ~inmodel(ind)
		str = "       ---        ";
		return;
	end

	coeff = coeff(ind);
	pval = pval(ind);

	coPre = " ";
	if coeff < 0
		coPre = "-";
		coeff = -coeff;
	end

	if coeff > 100 || coeff < 0.01
		coeffStr = coPre + "%2.1e";
	else
		coeffStr = coPre + "%2.3f";
	end

	if pval < 0.0001
		pStr = '(<0.0001)';
	elseif pval < 0.001
		pStr = '(<0.001)';
	elseif pval < 0.01
		pStr = sprintf('(%.3f)', pval);
	elseif pval < 0.1
		pStr = sprintf('(%.3f)', pval);
	else
		pStr = sprintf('(%.2f)', pval);
	end

	str = sprintf(coeffStr + " %9s", coeff, pStr);
end

function [str] = altNames()
	str = ["Latency","Max CMAP","Stim at 50\%","SR slope","Rheobase","SDTC","TEd (90--100ms)","TEh (90--100ms)","TEd peak","TEd undershoot","Accom half-time","TEh(10--20ms)","TEh overshoot","TEh(20--40ms)","TEd(10--20ms)","TEd (40--60ms)","TEh(slope, 140ms)","S2 accom.","Hyper. I/V slope","Min. I/V slope","Resting I/V slope","Superexcitable","Late subexcitable","Refractoriness 2.5","RRP","Refractoriness 2","Superex. at 5 ms","Superex. at 7 ms"];
end

function [ids] = altInds()
	ids = [16,5,1,4,3,2,18,10,22,20,24,19,21,27,11,17,28,23,25,7,6,12,13,26,9,29,31,30];
end

function [str] = stepWiseString(thisMeas, astCols, thisCol)
	[b, ~, modelp, inmodel] = stepwisefit(astCols, thisCol, 'penter', 0.002, 'premove', 0.01, 'display', 'off');

	if ~inmodel(1) && ~inmodel(2) && ~inmodel(3)
		str = "";
		return
	end

	strAge = dispCoeff(b, modelp, inmodel, 1);
	strSex = dispCoeff(b, modelp, inmodel, 2);
	strTemp = dispCoeff(b, modelp, inmodel, 3);

	str = sprintf("%20s & %18s & %18s & %18s", thisMeas, strAge, strSex, strTemp);
end
