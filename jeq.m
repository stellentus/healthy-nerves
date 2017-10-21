function eq = jeq(a, b, name)
    diffSum = sum(sum(abs(a-b) > 1e4*eps*ones(size(a))));
    eq = (diffSum == 0);

    if nargin == 3
		if diffSum
			disp(sprintf('%s are not equal (%d)', name, diffSum));
		else
			disp(sprintf('%s are equal', name));
		end
    end
end
