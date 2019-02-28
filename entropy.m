function entropy()
	pxy = [  % I can't calculate mutual information for my two matrices (or vectors) because I don't have their shared distribution, so I shouldn't try anything that needs this variable.
		.290 .180 .070 .020 .001;
		.180 .070 .020 .001 .001;
		.070 .020 .001 .001 .001;
		.020 .001 .001 .001 .001;
		.001 .001 .001 .001 .001;
	];

	x = [.1 .1 .1 .1 .1 .1 .1 .1 .1 .1];
	y = [.9 .001 .001 .001 .001 .001 .001 .001 .001 .092];
	check(x);
	check(y);

	fprintf("H(x) = %.3f\n", entr(x));
	fprintf("H(y) = %.3f\n", entr(y));
	fprintf("Hell(x,y) = %.3f\n", hell(x, y));
end

function check(x)
	tot = sum(x);
	if abs(tot-1) > 1e7
		error(sprintf("Vector didn't sum to 1 (%f)", sum(x), x));
	end
end

function en = entr(x)
	en = 0;
	for i=1:length(x)
		en = en - x(i) * log2(x(i));
	end
end

function he = hell(x, y)
	he = sqrt(1-sum(sqrt(x.*y)));
end
