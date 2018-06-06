%% ddNerves plots the nerve scores.
function ddNerves(threshold, alg, nanMethod, folderpath)
	if nargin < 4
		folderpath = 'data';
		if nargin < 3
			nanMethod = 'Mean';
			if nargin < 2
				alg = 'mog';
				if nargin < 1
					threshold = 0.1;
				end
			end
		end
	end

	data = ddScoresForPath(threshold, alg, nanMethod, folderpath);

	% Get indices to access each group
	outSCIInd = data.isSCI & (data.scores < data.thresholds);
	inSCIInd = data.isSCI & ~(data.scores < data.thresholds);
	outRatInd = data.isRat & (data.scores < data.thresholds);
	inRatInd = data.isRat & ~(data.scores < data.thresholds);
	outHealthyInd = data.isHealthy & (data.scores < data.thresholds);
	inHealthyInd = data.isHealthy & ~(data.scores < data.thresholds);

	x = data.values(:, 1);
	y = data.values(:, 2);
	z = data.values(:, 17);

	hold on;
	scatter3(x(inSCIInd), y(inSCIInd), z(inSCIInd), '.', 'MarkerEdgeColor','r');
	scatter3(x(outSCIInd), y(outSCIInd), z(outSCIInd), '*', 'MarkerEdgeColor','r');
	scatter3(x(inHealthyInd), y(inHealthyInd), z(inHealthyInd), '.', 'MarkerEdgeColor','k');
	scatter3(x(outHealthyInd), y(outHealthyInd), z(outHealthyInd), '*', 'MarkerEdgeColor','k');
	scatter3(x(inRatInd), y(inRatInd), z(inRatInd), '.', 'MarkerEdgeColor','b');
	scatter3(x(outRatInd), y(outRatInd), z(outRatInd), '*', 'MarkerEdgeColor','b');
end
