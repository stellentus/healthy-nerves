% makeAgeBatches splits the provided data by age into the requested bins.
% The first bin is age 1 to ageThresholds(1)-1.
% The second bin is age ageThresholds(1) to ageThresholds(2)-1.
% The last bin is age ageThresholds(end) and older (max 100).
function [ageLabels, values] = makeAgeBatches(values, ageThresholds)
	ages = values(:, 14);
	values = [values(:, 1:13) values(:, 15:end)]; % Optionally country labels could be appended here.

	labelForAge = repmat(length(ageThresholds)+1, 100, 1); % Initialize everything to the maximum label.
	lastAge = 1;
	for i = 1:length(ageThresholds)
		labelForAge(lastAge:ageThresholds(i)) = i;
		lastAge = ageThresholds(i);
	end

	ageLabels = labelForAge(ages);
end
