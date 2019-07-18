%% variance prints the variances
function [brs] = variance()
	load('bin/batch-normative.mat');

	strs = pad(measures);
	printTableOfVals("Variance for Measure", strs, std([canValues; japValues; porValues]), std(canValues), std(japValues), std(porValues));
	disp(" ");
	printTableOfVals("Mean for Measure", strs, mean([canValues; japValues; porValues]), mean(canValues), mean(japValues), mean(porValues));

	displayMeasure(1, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(2, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(3, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(5, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(14, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(20, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(21, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(25, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(26, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
	displayMeasure(29, measures, [canValues; japValues; porValues], canValues, japValues, porValues);
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

function displayMeasure(index, measures, comb, can, jap, por)
	maxLen = max(size(comb, 1), max(size(can, 1), max(size(jap, 1), size(por, 1))));
	vals = nan(maxLen, 4);
	vals(1:size(comb, 1), 1) = comb(:, index);
	vals(1:size(can, 1), 2) = can(:, index);
	vals(1:size(jap, 1), 3) = jap(:, index);
	vals(1:size(por, 1), 4) = por(:, index);

	addpath lib/CategoricalScatterplot;
	fig = figure('DefaultAxesFontSize', 18);
	CategoricalScatterplot(vals, [{'All'} {'Canada'} {'Japan'} {'Portugal'}]);
	title(['Comparison of' measures(index)]);
	rmpath lib/CategoricalScatterplot;

	addpath lib;
	savePlot(fig, false, 'img/variance', sprintf('norm-var-idx%92d-', index));
	rmpath lib;
end
