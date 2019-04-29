% countMissing prints a count of the missing values in a dataset.
% The provided filepath should contain measures, canValues, japValues, porValues, canNum, japNum, and porNum.
% The output is ready to be pasted into a LaTeX table, but is also human-readable.
% If the output variable 'nanPercent' is unused, the results are instead printed.
function [nanPercent] = countMissing(filepath)
	load(filepath);

	allValues = [canValues; japValues; porValues];
	allNum = size(allValues, 1);

	allNan = sum(isnan(allValues));
	canNan = sum(isnan(canValues));
	japNan = sum(isnan(japValues));
	porNan = sum(isnan(porValues));

	% Sort the missing allValues by frequency.
	[~, idx] = sort(allNan, 'descend');

	if nargout == 0
		% Fix formatting for LaTeX output
		measures = strrep(measures, "%", "\%");
		measures = strrep(measures, "( ", "(");

		% Get length of longest string for padding purposes
		padLen = max(strlength(measures(allNan~=0)));

		rowLen = 11;
		fprintf('%s & %s & %s & %s & %s \n', pad("Measure Name", padLen), pad("CA", rowLen), pad("JP", rowLen), pad("PO", rowLen), pad("ALL", rowLen));
		spacingString = strrep(pad(" ", rowLen), " ", "-");
		fprintf('%s & %s & %s & %s & %s \n', strrep(pad(" ", padLen), " ", "-"), spacingString, spacingString, spacingString, spacingString);
		for i=idx
			if allNan(i) == 0
				break;
			end
			canMissStr = missString(canNan(i), canNum);
			japMissStr = missString(japNan(i), japNum);
			porMissStr = missString(porNan(i), porNum);
			allMissStr = missString(allNan(i), allNum);
			fprintf('%s & %s & %s & %s & %s \\\\\n', pad(measures(i), padLen), canMissStr, japMissStr, porMissStr, allMissStr);
		end
	else
		nanPercent = allNan/allNum;
	end
end

function [str] = missString(numNan, numTot)
	if numNan == 0
		str = "    ---    ";
	else
		str = sprintf('%3d (%2.1f\\%%)', numNan, numNan/numTot*100);
	end
end
