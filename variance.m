%% variance prints the variances
function [brs] = variance()
	load('bin/batch-normative.mat');

	strs = pad(measures);
	printTableOfVals("Variance for Measure", strs, std([canValues; japValues; porValues]), std(canValues), std(japValues), std(porValues));
	disp(" ");
	printTableOfVals("Mean for Measure", strs, mean([canValues; japValues; porValues]), mean(canValues), mean(japValues), mean(porValues));
end

function [prc] = toPerc(thisS, allS)
	prc = (thisS/allS-1)*100 + 0.5;
end

function printTableOfVals(name, strs, comb, can, jap, por)
	fprintf('%s | ALL      | CANADA         | JAPAN          | PORTUGAL       \n', pad(name, strlength(strs(1))));
	fprintf('%s | -------- | -------------- | -------------- | -------------- \n', strrep(pad(" ", strlength(strs(1))), " ", "-"));
	for i=1:length(strs)
		fprintf('%s | % 8.3f | % 8.3f (% 3.0f) | % 8.3f (% 3.0f) | % 8.3f (% 3.0f) \n', strs(i), comb(i), can(i), toPerc(can(i),comb(i)), jap(i), toPerc(jap(i),comb(i)), por(i), toPerc(por(i),comb(i)));
	end
end
