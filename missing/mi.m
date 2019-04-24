% Code from https://www.researchgate.net/post/I_am_looking_for_a_Matlab_code_for_Multiple_imputation_method_for_missing_data_analysis_can_anybody_help_me
% The code can be referenced as:
% 	Abel Folch-Fortuny, Francisco Arteaga, Alberto Ferrer (2015). PCA model building with missing data: new proposals and a comparative study. Chemometrics and Intelligent Laboratory Systems 146, pp. 77–88.

% X is a data matrix with NaN in the missing data
% nChains is the number of independent chains (we use nChains = 10)
% chainLength is the len of each chain (we use chainLength = 100)
%
% DAmn:  estim. means for the nChains chains in nChains rows
% DAcv:  estim. Cov. matrices for the nChains chains DAcv(1).co, ..., DAcv(nChains).co
% mest: estimated means (mest = mean(DAmn))
% Sest: estimated covariance matrix (averaging DAcv(1).co, ..., DAcv(nChains).co)
% Y:    X with imputation made
%
function [DAmn, DAcv, mest, Sest, Y] = mi(X, nChains, chainLength)
	[n, nFeat] = size(X);
	mis = isnan(X);           % mis are the positions of the md in X
	r = ~mis;

	for i = n:-1:1
		% pat(i).Obs: the observed variables (subset of {1, 2, ..., nFeat})
		pat(i).Obs = find(r(i, :) == 1);
		% pat(i).Mis: the missing variables (subset of {1, 2, ..., nFeat})
		pat(i).Mis = find(r(i, :) == 0);
		% pat(i).nObs and pat(i).nMis are the size of pat(i).Obs and pat(i).Mis
		% pat(i).nObs = size(pat(i).Obs, 2); % #{pat(i).Obs}
		pat(i).nMis = size(pat(i).Mis, 2); % #{pat(i).Mis}
	end

	% Fill missing values with their column mean.
	[row, col] = find(isnan(X));
	X(mis) = 0;
	meanc = sum(X)./(n-sum(mis));
	for k = 1:length(row)
		X(row(k), col(k)) = meanc(col(k));
	end

	startMean = mean(X);
	startCov = cov(X);
	DAmn = zeros(nChains, nFeat);
	for chainIter = 1:nChains
		cv = startCov;
		mn = startMean;
		for itr = 1:chainLength
			% Do something to update the missing values in each row of X (I think based in PCA).
			for row = 1:n
				if pat(row).nMis > 0
					mn1 = mn(pat(row).Obs)';                  % nObs x 1
					mn2 = mn(pat(row).Mis)';                  % nMis x 1
					cv11 = cv(pat(row).Obs, pat(row).Obs);    % nObs x nObs
					cv12 = cv(pat(row).Obs, pat(row).Mis);    % nObs x nMis
					z1 = X(row, pat(row).Obs)';               % nObs x 1
					z2 = mn2 + cv12' * pinv(cv11) * (z1-mn1); % nMis x 1
					X(row, pat(row).Mis) = z2';               % 1 x nMis
				end
			end

			% Now update the mean based on the above loop.
			mn = mean(X);
			cv = cov(X);

			% Now update the mean based on the values just used.
			[mn, cv] = DrawPost(mn, cv, 10*n*n);
		end
		DAmn(chainIter, :) = mn;
		DAcv(chainIter).co = cv;
	end

	mest = mean(DAmn);
	Sest = zeros(nFeat, nFeat);
	for k = 1:nChains,
		Sest = Sest + DAcv(k).co;
	end
	Sest = Sest / nChains;

	% Applies stochastic regression with the posterior of the mean (mest)
	% and the covariance matrix (Sest)
	for i = 1:n             % for each row
		if pat(i).nMis > 0    % if there are missing values
			m1 = mest(1, pat(i).Obs)';          % nObs x 1
			m2 = mest(1, pat(i).Mis)';          % nMis x 1
			S11 = Sest(pat(i).Obs, pat(i).Obs);   % nObs x nObs
			S12 = Sest(pat(i).Obs, pat(i).Mis);   % nObs x nMis
			z1 = X(i, pat(i).Obs)';             % nObs x 1
			z2 = m2 + S12' * pinv(S11) * (z1-m1);  %nMis x 1
			X(i, pat(i).Mis) = z2';  % fill in the md positions of row i
		end
	end

	Y = X;
end

function [mnPost, cvPost] = DrawPost(mn, cv, n)
	diagCov = chol(cv / n);
	nFeat = size(cv, 1);
	if n <= 81 + nFeat
		% If there are very, very few samples relative to the number of features.
		x = randn(n-1, nFeat) * diagCov;
	else
		a = diag(sqrt(chi2rnd(n-(0:nFeat-1)))) + triu(randn(nFeat, nFeat), 1);
		x = a * diagCov;
	end

	cvPost = x' * x;
	mnPost = (mn' + chol(cvPost/(n-1))*randn(size(cv, 1), 1))';
end
