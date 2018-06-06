%% ddScoresForPath loads all Excel files and filters them based on names to get 'rat'
%% data and 'SCI' data. It marks the rest as targets, and calculates how likely each
%% rat and SCI point is an outlier.
function [data] = ddScoresForPath(threshold, nanMethod, folderpath)
	if nargin < 3
		folderpath = 'data';
		if nargin < 2
			nanMethod = 'Mean';
			if nargin < 1
				threshold = 0.1;
			end
		end
	end

	addpath import;
	[values, ~, ~] = importAllXLSX(nanMethod, folderpath);
	rmpath import;

	sciValues = [];
	ratValues = [];
	healthyValues = [];
	fields = fieldnames(values);
	for i = 1:numel(fields)
		if contains(fields{i}, 'rat', 'IgnoreCase', true)
			ratValues = [ratValues; values.(fields{i})];
		elseif contains(fields{i}, 'SCI', 'IgnoreCase', true)
			sciValues = [sciValues; values.(fields{i})];
		else
			healthyValues = [healthyValues; values.(fields{i})];
		end
	end

	% Create a labelled prtools dataset
	values = [sciValues; ratValues; healthyValues];
	sciLabel = ones(size(sciValues, 1), 1);
	ratLabel = ones(size(ratValues, 1), 1) * 2;
	healthyLabel = repmat(3, size(healthyValues, 1), 1);
	labels = [sciLabel; ratLabel; healthyLabel];
	prd = prdataset(values, labels);

	% Train the model
	inliers = target_class(prd, 3);
	w = mog_dd(inliers, threshold, 5);
	scores = +(values * w);

	data = struct();
	data.values = values;
	data.scores = scores(:, 1);
	data.thresholds = scores(:, 2);
	data.isSCI = false(size(values, 1), 1);
	data.isRat = data.isSCI;
	data.isHealthy = data.isSCI;
	data.isSCI(1:size(sciValues, 1)) = true;
	data.isRat(size(sciValues, 1)+1:size(sciValues, 1)+size(ratValues, 1)) = true;
	data.isHealthy(size(sciValues, 1)+size(ratValues, 1)+1:end) = true;
end
