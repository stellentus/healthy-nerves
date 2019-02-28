function hd = hellingerFromMatrixSimple(x, y)
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
			error("hellingerFromMatrixSimple expects x of size (n, f) and y of size (m, f)")
		end
	end
	clear yFeat x_a y_a;

	hd = 0;
	for i=1:nFeat
		hd = hd + hellinger(x(:, i), y(:, i))^2;
	end
	hd = sqrt(hd)/nFeat;
end
