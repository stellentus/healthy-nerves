%% getAgeMatchedBatches returns a list of BatchAnalyzer that use age-matched groups from the countries.
function [bas] = getAgeMatchedBatches(iters, sampleFraction, filepath)
	load(filepath);

	ba = BatchAnalyzer("Normative", 3, [canValues; japValues; porValues], [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)], 'iters', iters, 'sampleFraction', sampleFraction);

	% Drop some rows so the histograms are more balanced by age
	[canValues, japValues, porValues] = matchAges(canValues, japValues, porValues);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	bas = [ba];

	bas = [bas BatchAnalyzer("Age-matched data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No CA", 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No JA", 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No PO", 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
end
