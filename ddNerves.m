%% ddNerves plots the nerve scores.
function ddNerves(threshold, nanMethod, folderpath)
	if nargin < 3
		folderpath = 'data';
		if nargin < 2
			nanMethod = 'Mean';
			if nargin < 1
				threshold = 0.1;
			end
		end
	end

	data = ddScoresForPath(threshold, nanMethod, folderpath);

	% Get indices to access each group
	outSCIInd = data.isSCI & (data.scores < data.thresholds);
	inSCIInd = data.isSCI & ~(data.scores < data.thresholds);
	outRatInd = data.isRat & (data.scores < data.thresholds);
	inRatInd = data.isRat & ~(data.scores < data.thresholds);
	outHealthyInd = data.isHealthy & (data.scores < data.thresholds);
	inHealthyInd = data.isHealthy & ~(data.scores < data.thresholds);

	x = data.values(:, 1);
	y = data.values(:, 2);

	hold on;
	plot(x(inSCIInd), y(inSCIInd), '.r');
	plot(x(outSCIInd), y(outSCIInd), '*r');
	plot(x(inHealthyInd), y(inHealthyInd), '.k');
	plot(x(outHealthyInd), y(outHealthyInd), '*k');
	plot(x(inRatInd), y(inRatInd), '.b');
	plot(x(outRatInd), y(outRatInd), '*b');
end
