%% ddNerves plots the nerve scores.
function [data] = ddNerves(threshold, alg, nanMethod, folderpath)
	if nargin < 4
		folderpath = 'data';
		if nargin < 3
			nanMethod = 'Mean';
			if nargin < 2
				alg = 'mog';
				if nargin < 1
					threshold = 0.01;
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

	% New redo all of the above for the PCA components
	addpath poster;
	[coeff, m] = transform(data.values(data.isHealthy, :), 'svd');
	rmpath poster;
	scores = data.values*coeff-m;

	xIndex = 1;
	yIndex = 2;
	zIndex = 3;
	xAsPCA = false;
	yAsPCA = false;
	zAsPCA = false;

	figure;
	set(gcf, 'units', 'points', 'position', [0, 40, 400, 400]);

	maxIndex = size(data.values, 2);

	function plotData(~, ~)
		if xAsPCA
			x = scores(:, xIndex);
		else
			x = data.values(:, xIndex);
		end
		if yAsPCA
			y = scores(:, yIndex);
		else
			y = data.values(:, yIndex);
		end
		if zAsPCA
			z = scores(:, zIndex);
		else
			z = data.values(:, zIndex);
		end

		cla reset;
		hold on;
		scatter3(x(inSCIInd), y(inSCIInd), z(inSCIInd), '.', 'MarkerEdgeColor','r');
		scatter3(x(outSCIInd), y(outSCIInd), z(outSCIInd), '*', 'MarkerEdgeColor','r');
		scatter3(x(inHealthyInd), y(inHealthyInd), z(inHealthyInd), '.', 'MarkerEdgeColor','k');
		scatter3(x(outHealthyInd), y(outHealthyInd), z(outHealthyInd), '*', 'MarkerEdgeColor','k');
		scatter3(x(inRatInd), y(inRatInd), z(inRatInd), '.', 'MarkerEdgeColor','b');
		scatter3(x(outRatInd), y(outRatInd), z(outRatInd), '*', 'MarkerEdgeColor','b');
		legend({'SCI Healthy', 'SCI Unhealthy', 'Control Healthy', 'Control Unhealthy', 'Rat Healthy', 'Rat Unhealthy'}, 'Location','northeast', 'NumColumns', 2, 'Orientation', 'horizontal', 'FontSize', 12);
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
		[xIndex, xAsPCA] = indexForString(xIndex);
		plotData();
	end

	function popY(hObject, eventdata)
		yIndex = get(hObject,'Value');
		[yIndex, yAsPCA] = indexForString(yIndex);
		plotData();
	end

	function popZ(hObject, eventdata)
		zIndex = get(hObject,'Value');
		[zIndex, zAsPCA] = indexForString(zIndex);
		plotData();
	end

	function [idx, isPCA] = indexForString(idx)
		isPCA = idx > maxIndex;
		if isPCA
			idx = idx - maxIndex;
		end
	end

	ih = uicontrol('Style', 'popup', 'String', genStrings(maxIndex, 'X'), 'Position', [30 0 100 50], 'Value', 1, 'Callback', @popX);
	ih = uicontrol('Style', 'popup', 'String', genStrings(maxIndex, 'Y'), 'Position', [140 0 100 50], 'Value', 2, 'Callback', @popY);
	ih = uicontrol('Style', 'popup', 'String', genStrings(maxIndex, 'Z'), 'Position', [250 0 100 50], 'Value', 3, 'Callback', @popZ);
end

function [strs] = genStrings(maxInt, axis)
	strs = {};
	for i = 1:maxInt
		strs = [strs sprintf('%s %d', axis, i)];
	end
	for i = 1:maxInt
		strs = [strs sprintf('PCA %s %d', axis, i)];
	end
end
