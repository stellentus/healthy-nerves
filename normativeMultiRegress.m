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
		fprintf("ID | Sex Coeff (p)      | Age Coeff (p)      | Temp Coeff (p)     | Measure Name\n");
		fprintf("-- | ------------------ | ------------------ | ------------------ | ------------------------------------\n");
	end

	for i=1:length(measures)
		if i == sexIndex || i == ageIndex || i == tempIndex
			continue;
		end

		thisCol = values(:, i);
		% It might be both linear and log, in which case we use linear, not this if statement.
		if ~(isLinM(i) && isLinF(i)) && isLogM(i) && isLogF(i)
			thisCol = log(abs(thisCol));
		end

		[b, ~, modelp, inmodel] = stepwisefit(astCols, thisCol, 'penter', 0.002, 'premove', 0.01, 'display', 'off');
		strAge = dispCoeff(b(1), modelp(1), inmodel(1));
		strSex = dispCoeff(b(2), modelp(2), inmodel(2));
		strTemp = dispCoeff(b(3), modelp(3), inmodel(3));
		fprintf("%02d | %18s | %18s | %18s | %s\n", i, strAge, strSex, strTemp, measures(i))
	end
end

function [str] = dispCoeff(coeff, pval, inmodel)
	if ~inmodel
		str = "       ---        ";
		return;
	end

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
