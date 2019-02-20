function [brs] = printStats()
	load('bin/batch-normative.mat');

	% Get and print count of each group and age range
	canNum = printIndividualStats(canValues, 'Canada');
	japNum = printIndividualStats(japValues, 'Japan');
	porNum = printIndividualStats(porValues, 'Portugal');
	legNum = printIndividualStats(legValues, 'Legs');
end

function [num] = printIndividualStats(vals, str)
	num = size(vals, 1);
	male = countMales(vals);
	[ageMin, ageMax] = ageRange(vals);
	fprintf('There are %d participants from %s (%d male) ages %d to %d.\n', num, str, male, ageMin, ageMax);
end

function [males] = countMales(vals)
	males = sum(ismember(vals(:, 15), [1.0]));
end

function [minAge, maxAge] = ageRange(vals)
	minAge = min(vals(:, 14));
	maxAge = max(vals(:, 14));
end
