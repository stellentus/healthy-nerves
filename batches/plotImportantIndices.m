%% plotImportantIndices plots the indices causing the most batching. It assumes it is receiving a bas calculated by getDeletedFeatureBatches.
function plotImportantIndices(bas)
	[~, ind] = sort([bas.CRI_mean]);
	sortedBas = bas(ind);
	scores = zeros(1,31);
	for i=2:length(sortedBas)
		str = char(sortedBas(i).Name);
		str = str(9:end-1);
		vals = sscanf(str, '%f');
		for j=1:length(vals)
			scores(vals(j)) = scores(vals(j)) + i-1;
		end
	end

	[~, ind] = sort(scores);
	bar(scores(ind));
	xticklabels(ind)
	xticks(1:1:length(ind))
	xtickangle(90)
end

% This results in the following indices, starting with the ones causing the most batching (when 3 are removed):
%   ind = [18, 25, 14, 11, 2, 6, 22, 19, 1, 17, 3, 10, 24, 27, 28, 20, 13, 16, 5, 21, 15, 8, 7, 4, 23, 26, 9, 30, 29, 12, 31];
%   scores = [832022, 680902, 885430, 1165585, 1008248, 736577, 1153414, 1134581, 1294235, 907675, 657425, 1453802, 998737, 584319, 1030115, 1004244, 840036, 421082, 815768, 953358, 1027494, 776020, 1195564, 946553, 545174, 1254188, 948651, 952124, 1330570, 1296234, 1477361];

% 18 TEd(90-100ms)
% 25 Hyperpol. I/V slope
% 14 Age (years)
% 11 TEd(10-20ms)
% 02 Strength-duration time constant (ms)
