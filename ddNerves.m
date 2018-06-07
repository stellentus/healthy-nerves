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

	addpath import;
	[inliers, data] = importPRDataset(nanMethod, folderpath);
	rmpath import;

	% Calculate scores
	scores = +(data.values * ddModel(inliers, threshold, alg));
	data.scores = scores(:, 1);
	data.thresholds = scores(:, 2);

	% Get indices to access each group
	outSCIInd = data.isSCI & (data.scores < data.thresholds);
	inSCIInd = data.isSCI & ~(data.scores < data.thresholds);
	outRatInd = data.isRat & (data.scores < data.thresholds);
	inRatInd = data.isRat & ~(data.scores < data.thresholds);
	outHealthyInd = data.isHealthy & (data.scores < data.thresholds);
	inHealthyInd = data.isHealthy & ~(data.scores < data.thresholds);

	xIndex = 1;
	yIndex = 2;
	zIndex = 3;  %17
	figure;
	set(gcf, 'units', 'points', 'position', [0, 40, 400, 400]);

	maxIndex = size(data.values, 2);

	function plotData(~, ~)
		x = data.values(:, xIndex);
		y = data.values(:, yIndex);
		z = data.values(:, zIndex);

		cla reset;
		hold on;
		scatter3(x(inSCIInd), y(inSCIInd), z(inSCIInd), '.', 'MarkerEdgeColor','r');
		scatter3(x(outSCIInd), y(outSCIInd), z(outSCIInd), '*', 'MarkerEdgeColor','r');
		scatter3(x(inHealthyInd), y(inHealthyInd), z(inHealthyInd), '.', 'MarkerEdgeColor','k');
		scatter3(x(outHealthyInd), y(outHealthyInd), z(outHealthyInd), '*', 'MarkerEdgeColor','k');
		scatter3(x(inRatInd), y(inRatInd), z(inRatInd), '.', 'MarkerEdgeColor','b');
		scatter3(x(outRatInd), y(outRatInd), z(outRatInd), '*', 'MarkerEdgeColor','b');
		view(3);
	end

	plotData();

	function [str] = buttonString(ind, axis)
		str = sprintf('Increment %s (%d)', axis, ind);
	end

	function [ind] = updateIndex(ind)
		ind = ind+1;
		if ind > maxIndex
			ind = 1;
		end
	end

	function popX(hObject, eventdata)
		xIndex = get(hObject,'Value');
		plotData();
	end

	function popY(hObject, eventdata)
		yIndex = get(hObject,'Value');
		plotData();
	end

	function popZ(hObject, eventdata)
		zIndex = get(hObject,'Value');
		plotData();
	end

	ih = uicontrol('Style', 'popup', 'String', genStrings(maxIndex, 'X'), 'Position', [30 0 100 50], 'background', 'green', 'Value', 1, 'Callback', @popX);
	ih = uicontrol('Style', 'popup', 'String', genStrings(maxIndex, 'Y'), 'Position', [140 0 100 50], 'background', 'green', 'Value', 2, 'Callback', @popY);
	ih = uicontrol('Style', 'popup', 'String', genStrings(maxIndex, 'Z'), 'Position', [250 0 100 50], 'background', 'green', 'Value', 3, 'Callback', @popZ);
end

function [strs] = genStrings(maxInt, axis)
	strs = {};
	for i = 1:maxInt
		strs = [strs sprintf('%s %d', axis, i)];
	end
end
