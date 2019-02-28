% 1. First, gather all of the data together to get bounds for the bins. Consider dense bins near the middle and sparse bins farther out. There's no reason (I think) for bins to be evenly spaced.
% 2. Get discrete probability distribution for each feature, for each dataset. Now imagine each observation could be in one bin for each of the 30 measures. If there are 10 bins per probability, there are 10^30 different possible bin combinations that an observation could be in. So turn the probability histograms into this vector of length 10^30 for each of the 3 datasets.
% 3. Calculate the Hellinger distance.
% Problems:
%	* This is probably too sparse to be meaningful.
% 	* I don't know how to calculate standard deviation.
% Note that IF the variables are normally distributed, I might be able to find a distance metric that just uses the mean and standard deviation (e.g. Bhattacharyya distance). Then I could estimate the mean and std for each feature separately and feed that into this algorithm.
function hd = hellinger(x, y)
	% Rotate if necessary
	if size(x, 1) == 1 && size(x, 2) ~= 1
		x = x';
		y = y';
	end
	if size(x, 2) ~= 1 || size(y, 2) ~= 1
		error("Hellinger distance can't be calculated on these inputs")
	end

	both = [x; y];
	nbins = 10;
	bins = quantile(both, nbins-1);
	countsBoth = histcounts(both, [-inf, bins, inf]);
	countsX = histcounts(x, [-inf, bins, inf]);
	countsY = histcounts(y, [-inf, bins, inf]);
	probX = countsX/sum(countsX);
	probY = countsY/sum(countsY);
	hd = sqrt(1-sum(sqrt(probX.*probY)));
end
