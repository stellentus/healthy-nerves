% fillCCA just drops missing values
function [filledX, covr] = fillCCA(missingX, completeX, missingMask, arg)
	filledX = missingX;    % Nothing is filled...
	covr = cov(completeX); % ...so covariance is only based on complete rows.
end
