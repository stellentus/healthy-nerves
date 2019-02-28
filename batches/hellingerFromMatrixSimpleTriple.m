function hd = hellingerFromMatrixSimpleTriple(x, y, z)
	% Confirm input sizes are correct. Expect any number of rows, but the columns (features) should be the same. (But if the input is transposed, work with it.)
	[x_a, nFeat] = size(x);
	[y_a, yFeat] = size(y);
	[z_a, zFeat] = size(z);
	if nFeat ~= yFeat || nFeat ~= zFeat
		if x_a == y_a && x_a == z_a
			% Probably the user passed rows as features and columns as samples.
			x = x';
			y = y';
			z = z';
			nFeat = x_a;
		else
			error("hellingerFromMatrixSimpleTriple expects x of size (n, f) and y of size (m, f)")
		end
	end
	clear yFeat zFeat x_a y_a z_a;

	hd = 0;
	for i=1:nFeat
		hd = hd + hellinger3(x(:, i), y(:, i), z(:, i))^2;
	end
	hd = sqrt(hd)/nFeat;
end
