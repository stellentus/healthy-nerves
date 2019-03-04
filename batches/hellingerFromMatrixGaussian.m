% Create a gaussian distribution for each feature based on the combined data, and then see how different the individual datasets are.
% Some features are definitely not gaussian (e.g. non-negative or bimodal), but this might still give something useful.
function hd = hellingerFromMatrixGaussian(X, Y, Z)
	useZ = nargin == 3;
	if ~useZ
		Z = [];
	end

	% Confirm input sizes are correct. Expect any number of rows, but the columns (features) should be the same. (But if the input is transposed, work with it.)
	[numX, numFeat] = size(X);
	[numY, numFeatY] = size(Y);
	[numZ, numFeatZ] = size(Z);
	if numFeat ~= numFeatY || (useZ && numFeat ~= numFeatZ)
		if numX == numY && (~useZ || numX == numZ)
			% Probably the user passed rows as features and columns as samples.
			X = X';
			Y = Y';
			Z = Z';
			numFeat = numX;
		else
			error("hellingerFromMatrixGaussian expects X of size (n, f), Y of size (m, f), and optional Z of size (p, f)")
		end
	end
	clear numFeatY numFeatZ numX numY numZ;

	mnX = mean(X)';
	coX = cov(X);
	mnY = mean(Y)';
	coY = cov(Y);
	mnZ = mean(Z)';
	coZ = cov(Z);

	hd = multiDist(mnX, coX, mnY, coY);

	if useZ
		hdYZ = multiDist(mnY, coY, mnZ, coZ);
		hdXZ = multiDist(mnX, coX, mnZ, coZ);
		hd = hd + hdYZ + hdXZ;
		hd = hd/3;
	end

	hd = sqrt(hd);
end

function hd = multiDist(mnA, coA, mnB, coB)
	invCov = pinv((coA+coB)/2);
	coeff = -1/8*(mnA-mnB)'*invCov*(mnA-mnB);
	if det(coA) < eps || det(coB) < eps
		error(sprintf("NO %f %f", det(coA), det(coB)));
	end

	prefix = ((det(coA)*det(coB))^.25)/(det((coA+coB)/2)^.5);
	hd = 1 - prefix*exp(coeff);
end
