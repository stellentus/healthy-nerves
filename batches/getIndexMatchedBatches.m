%% getIndexMatchedBatches returns a list of BatchAnalyzer that use index-matched groups from the countries (e.g. batches based on age).
function [bas] = getIndexMatchedBatches(iters, sampleFraction, filepath, index)
	load(filepath);

	ba = BatchAnalyzer("Normative", 3, [canValues; japValues; porValues], [ones(size(canValues, 1), 1); ones(size(japValues, 1), 1) * 2; repmat(3, size(porValues, 1), 1)], 'iters', iters, 'sampleFraction', sampleFraction);

	% Drop some rows so the histograms are more balanced by age
	[canValues, japValues, porValues] = matchIndex(canValues, japValues, porValues, index);

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	bas = [ba];

	bas = [bas BatchAnalyzer(sprintf("%d-batched data", index), 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No CA", 2, [japValues; porValues], [ones(japNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No JA", 2, [canValues; porValues], [ones(canNum, 1); ones(porNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
	bas = [bas BatchAnalyzer("No PO", 2, [canValues; japValues], [ones(canNum, 1); ones(japNum, 1) * 2], 'iters', iters, 'sampleFraction', sampleFraction)];
end

function [canAgeValues, japAgeValues, porAgeValues] = matchIndex(canValues, japValues, porValues, index)
	% Get the maximum amount that can be contributed to each bracket, which is the minimum (by %) of any nation's ability to contribute.
	canBins = getHist(canValues, index);
	japBins = getHist(japValues, index);
	porBins = getHist(porValues, index);
	minBins = min([canBins;japBins;porBins]);
	canAgeValues = getValuesCappedByAge(canValues, minBins, index);
	japAgeValues = getValuesCappedByAge(japValues, minBins, index);
	porAgeValues = getValuesCappedByAge(porValues, minBins, index);
end

function bins = getHist(values, index)
	bins = histcounts(values(:, index), 10:10:90);
	bins = bins/sum(bins);
end

function ageValues = getValuesCappedByAge(values, minBins, index)
	numRows = size(values, 1);
	ageBins = round(minBins * numRows); % Desired number of rows by age
	ageValues = [];

	% Permute the values so we draw them in a random order
	values = values(randperm(numRows), :);
	for i=1:numRows
		thisRow = values(i, :);
		thisAge = thisRow(index);
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
