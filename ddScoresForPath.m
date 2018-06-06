%% ddScoresForPath loads all Excel files and filters them based on names to get 'rat'
%% data and 'SCI' data. It marks the rest as targets, and calculates how likely each
%% rat and SCI point is an outlier.
function [sciScores, ratScores, healthyScores] = ddScoresForPath(nanMethod, folderpath)
	if nargin < 2
		folderpath = 'data';
		if nargin < 1
			nanMethod = 'Mean';
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
	sciLabel = ones(size(sciValues, 1), 1);
	ratLabel = ones(size(ratValues, 1), 1) * 2;
	healthyLabel = repmat(3, size(healthyValues, 1), 1);
	labels = [sciLabel; ratLabel; healthyLabel];
	prd = prdataset([sciValues; ratValues; healthyValues], labels);

	% Train the model
	inliers = target_class(prd, 3);
	w = mog_dd(inliers, 0.1, 5);

	% Calculate scores
	sciScores = +(sciValues * w);
	ratScores = +(ratValues * w);
	healthyScores = +(healthyValues * w);
end
