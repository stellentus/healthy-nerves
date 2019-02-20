function [inds] = indicesForPlotNoTE20(plot)
	switch plot
		case "SR"
			inds = [1,4,5];
		case "IV"
			inds = [6,7,25];
		case "QT"
			inds = [2,3];
		case "TEd"
			inds = [22,11,17,18,20,24,23];
		case "TEh"
			inds = [10,19,21,27,28];
		case "Meta"
			inds = [8,14,15,16];
		case "RC"
			inds = [26,9,29,30,31,12,13];
		case "all"
			inds = [1:31]; % includes all of the above plots
		otherwise
			inds = [];
			warning("Could not get indices");
	end
end
