% covError compares cov(X) values
function [err] = covError(originalCov, filledCov)
	err = mean(mean((originalCov - filledCov) .^ 2));
end
