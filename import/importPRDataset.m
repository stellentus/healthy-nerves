%% importPRDataset loads all Excel files at the given path as a PR dataset.
function [prInliers, data] = importPRDataset(nanMethod, folderpath)
	[values, ~, ~] = importAllXLSX(nanMethod, folderpath);

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
	prInliers = target_class(prd, 3);

	if nargout > 1
		data = struct();
		data.values = values;
		data.isSCI = false(size(values, 1), 1);
		data.isRat = data.isSCI;
		data.isHealthy = data.isSCI;
		data.isSCI(1:size(sciValues, 1)) = true;
		data.isRat(size(sciValues, 1)+1:size(sciValues, 1)+size(ratValues, 1)) = true;
		data.isHealthy(size(sciValues, 1)+size(ratValues, 1)+1:end) = true;
	end
end
