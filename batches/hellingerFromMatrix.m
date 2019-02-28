function hd = hellingerFromMatrix(x, y)
	% Confirm input sizes are correct. Expect any number of rows, but the columns (features) should be the same. (But if the input is transposed, work with it.)
	[x_a, nFeat] = size(x);
	[y_a, yFeat] = size(y);
	if nFeat ~= yFeat
		if x_a == y_a
			% Probably the user passed rows as features and columns as samples.
			x = x';
			y = y';
			nFeat = x_a;
		else
			error("hellingerFromMatrix expects x of size (n, f) and y of size (m, f)")
		end
	end
	clear yFeat x_a y_a;

	nbins = 10;
	probsX = zeros(nbins, nFeat);
	probsY = zeros(nbins, nFeat);
	for i=1:nFeat
		both = [x(:, i); y(:, i)];
		bins = quantile(both, nbins-1);
		countsBoth = histcounts(both, [-inf, bins, inf]);
		countsX = histcounts(x(:, i), [-inf, bins, inf]);
		countsY = histcounts(y(:, i), [-inf, bins, inf]);
		probsX(:, i) = countsX/sum(countsX);
		probsY(:, i) = countsY/sum(countsY);
	end
end

function prob = thisProbDeeper(x, prob, thisRow)

end
