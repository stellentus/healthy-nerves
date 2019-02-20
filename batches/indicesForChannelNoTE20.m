function [inds] = indicesForChannelNoTE20(channel)
	% This is just based on my visual inspection of the available data from a page of ±40% plots Dr. Jones gave me.
	switch channel
		case "Ci"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,19,27,10,28,21];
		case "Cmy"
			inds = [9,29,25,10];
		case "Gmy"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,19,27,10,28,21];
		case "GKf"
			inds = [9,26,29,30,31,12,6,7,11,22,17,24,18,23,20];
		case "GKfi"
			inds = [26,30,31,12,6,7,22,17,24,18,23,20,10];
		case "GKir"
			inds = [30,12,25,6,7,22,17,24,18,20,27,10,21];
		case "GKs"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,20,27,10,21];
		case "GLk"
			inds = [25,6,7,22,23,27,10,21];
		case "GLki"
			inds = [25,6,7,22,17,24,18,27,10,21];
		case "PNa"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,10];
		case "PNap"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,23,20,27];
		case "vleak"
			inds = [9,26,29,30,31,12,13,25,6,7,11,22,17,24,18,20,19,27,10,28,21];
		case "all"
			inds = [6:7,9:13,17:31]; % includes all of the above channels
		otherwise
			inds = [];
			error("Could not get indices");
	end
end
