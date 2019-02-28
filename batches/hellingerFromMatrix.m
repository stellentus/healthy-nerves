function hd = hellingerFromMatrix(x, y, z)
	useZ = nargin == 3;
	if ~useZ
		z = [];
	end

	% Confirm input sizes are correct. Expect any number of rows, but the columns (features) should be the same. (But if the input is transposed, work with it.)
	[x_a, nFeat] = size(x);
	[y_a, yFeat] = size(y);
	[z_a, zFeat] = size(z);
	if nFeat ~= yFeat || (useZ && nFeat ~= zFeat)
		if x_a == y_a && (~useZ || x_a == z_a)
			% Probably the user passed rows as features and columns as samples.
			x = x';
			y = y';
			z = z';
			nFeat = x_a;
		else
			error("hellingerFromMatrix expects x of size (n, f) and y of size (m, f)")
		end
	end
	clear yFeat zFeat x_a y_a z_a;

	nbins = 2; % Must be 9 or less because we represent below as a digit
	allMat = [x; y; z];
	numSamples = size(allMat, 1);
	bins = zeros(nbins+1, nFeat);

	for ft=1:nFeat
		bins(:, ft) = [-inf; quantile(allMat(:, ft), nbins-1)'; inf];
	end

	mapAll = containers.Map;
	probAll = 1/numSamples;

	mapX = containers.Map;
	probX = 1/size(x, 1);
	for sam=1:size(x, 1);
		id = binIDForSample(bins, x(sam, :));
		mapX = addProb(mapX, id, probX);
		mapAll = addProb(mapAll, id, probAll);
	end

	mapY = containers.Map;
	probY = 1/size(y, 1);
	for sam=1:size(y, 1);
		id = binIDForSample(bins, y(sam, :));
		mapY = addProb(mapY, id, probY);
		mapAll = addProb(mapAll, id, probAll);
	end

	mapZ = containers.Map;
	if useZ
		probZ = 1/size(z, 1);
		for sam=1:size(z, 1);
			id = binIDForSample(bins, z(sam, :));
			mapZ = addProb(mapZ, id, probZ);
			mapAll = addProb(mapAll, id, probAll);
		end
	end

	ks = keys(mapAll);
	numK = length(ks);
	pX = zeros(numK, 1);
	pY = zeros(numK, 1);
	pZ = zeros(numK, 1);
	for i = 1:numK
		pX(i) = valAt(mapX, ks{i});
		pY(i) = valAt(mapY, ks{i});
		pZ(i) = valAt(mapZ, ks{i});
	end

	if useZ
		hd = hellinger(pX, pY, pZ);
	else
		hd = hellinger(pX, pY);
	end
end

function id = binIDForSample(bins, sample)
	% For each feature, figure out the bin this sample matches
	nFeat = size(bins, 2);
	id = char(nFeat);
	for i=1:nFeat
		binNum = find(histcounts(sample(i), bins(:, i)));
		id(i) = 16*3 + binNum; % Append ASCII for the digit we found.
	end
end

function mp = addProb(mp, id, prob)
	if isKey(mp, id)
		mp(id) = mp(id) + prob;
	else
		mp(id) = prob;
	end
end

function val = valAt(mp, id)
	if isKey(mp, id)
		val = mp(id);
	else
		val = 0;
	end
end
