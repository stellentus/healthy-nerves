% batcherFigures plots figures for the preliminary batch effect analysis.
function batcherFigures()
	iter = 30;
	sampleFraction = 0.8;
	normativeFile = "bin/batch-normative.mat";

	addpath batches;

	bas = getMiscSeekerBatches(iter, sampleFraction, normativeFile, false);

	% Calculate BE and print
	for i = 1:length(bas)
		calculateBatch(bas(i));
	end

	plotBas(bas);

	rmpath batches;
end
