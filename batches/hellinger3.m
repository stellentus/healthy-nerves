% There is a version of this for 3, but I just invented the following.
function hd = hellinger3(x, y, z)
	allMat = [x; y; z];
	nbins = 10;
	bins = quantile(allMat, nbins-1);
	countsBoth = histcounts(allMat, [-inf, bins, inf]);
	countsX = histcounts(x, [-inf, bins, inf]);
	countsY = histcounts(y, [-inf, bins, inf]);
	countsZ = histcounts(z, [-inf, bins, inf]);
	probX = countsX/sum(countsX);
	probY = countsY/sum(countsY);
	probZ = countsZ/sum(countsZ);
	hd = sqrt(1-sum(sqrt(probX.*probY.*probZ)));
end
