% covError compares cov(X) values
function [err] = covError(originalCov, filledCov)
	err = 0;
	for i = 1:size(originalCov, 1)
		for j = 1:size(originalCov, 2)
			difference = originalCov(i, j) - filledCov(i, j);
			err = err + (difference ^ 2);
		end
	end
	err = err / (size(originalCov, 1) * size(originalCov, 2));
end
