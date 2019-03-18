%% getAgeMatchedBatches returns a list of BatchAnalyzer that use age-matched groups from the countries.
function [bas] = getAgeMatchedBatches(iters, sampleFraction, filepath)
	load(filepath);

	ba = BatchAnalyzer("Normative", 3, [canValues; japValues; porValues], [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)], 'iters', iters, 'sampleFraction', sampleFraction);

	% Drop some rows so the histograms are more balanced by age
	[canValues, japValues, porValues] = matchAges(canValues, japValues, porValues);

	canNum = size(canValues, 1);
	japNum = size(japValues, 1);
	porNum = size(porValues, 1);
	legNum = size(legValues, 1);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	bas = [ba];

	bas = [bas BatchAnalyzer("Age-matched data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No Can", 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No Jap", 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No Por", 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
end

function [canAgeValues, japAgeValues, porAgeValues] = matchAges(canValues, japValues, porValues)
	% Get the maximum amount that can be contributed to each bracket, which is the minimum (by %) of any nation's ability to contribute.
	canBins = getHist(canValues);
	japBins = getHist(japValues);
	porBins = getHist(porValues);
	minBins = min([canBins;japBins;porBins]);
	canAgeValues = getValuesCappedByAge(canValues, minBins);
	japAgeValues = getValuesCappedByAge(japValues, minBins);
	porAgeValues = getValuesCappedByAge(porValues, minBins);
end

function bins = getHist(values)
	ageIndex = 14;
	bins = histcounts(values(:, ageIndex), 10:10:90);
	bins = bins/sum(bins);
end

function ageValues = getValuesCappedByAge(values, minBins)
	ageIndex = 14;

	numRows = size(values, 1);
	ageBins = round(minBins * numRows); % Desired number of rows by age
	ageValues = [];

	% Permute the values so we draw them in a random order
	values = values(randperm(numRows), :);
	for i=1:numRows
		thisRow = values(i, :);
		thisAge = thisRow(ageIndex);
		binNum = floor(thisAge/10);
		if ageBins(binNum) > 0
			% We need another in this bin, so append it
			ageBins(binNum) = ageBins(binNum) - 1;
			ageValues = [ageValues; thisRow];
		% else we have enough, so don't add anymore
		end
	end

	if sum(ageBins) > 0
		error("Something didn't work");
	end
end
