function plotBatches()
	load('bin/missing-normative.mat');
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	plotPair("Threshold Electrotonus", values, labels, measures, 11, 18);
	plotPair("Recovery Cycle", values, labels, measures, 29, 13);
	plotPair("Charge Duration", values, labels, measures, 3, 2);
	plotPair("Threshold I/V", values, labels, measures, 6, 25);
	plotPair("Stimulus Response", values, labels, measures, 5, 1);
	plotPair("Other", values, labels, measures, 8, 14);
end
