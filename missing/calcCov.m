% calcCov calculates the covariance from filled data
function [covr] = calcCov(completeX, filledX)
	covr = cov([completeX; filledX]);
end
