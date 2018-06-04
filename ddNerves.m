%% ddNerves loads all Excel files and filters them based on names to get 'rat' data
%% and 'SCI' data. It marks the rest as targets, and calculates how likely each rat
%% and SCI point is an outlier.
function ddNerves()
	[values, ~, measures] = importAllXLSX('Mean', 'data');

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

	% Now use dd_tools
end
