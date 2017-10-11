% shortenNames creates a shortened version of the provided names.
% The names will go from a-z, then A-Z (and then punctuation or something).
function [shortNames] = shortenNames(names)
	% Create short names
	shortNames = [];
	startLabel = 'a';
	for i = 1:length(names)
		if startLabel > 'z'
			startLabel = 'A';
		end
		shortNames = [shortNames; cellstr(startLabel)];
		startLabel = char(startLabel + 1);
	end
	shortNames = shortNames';
end
