% plot551 does the CMPUT 551 preliminary analysis.
function plot551(Xtrain, Xtest, Xtest_orig, X, Xall)
	% Calculate factors
	[F, P, ~, ~, ~, mu] = pca(Xtrain);
	k = length(mu);
	F = F';
	Mutest = repmat(mu, size(Xtest, 1), 1);
	Mutrain = repmat(mu, size(Xtrain, 1), 1);
	Muall = repmat(mu, size(Xall, 1), 1);

	% Calculate factors
	[F, P, ~, ~, ~, mu] = pca(Xtrain);
	F = F';
	Mutest = repmat(mu, size(Xtest, 1), 1);
	Mutrain = repmat(mu, size(Xtrain, 1), 1);
	Muall = repmat(mu, size(Xall, 1), 1);


	trainError = zeros(k);
	for i = 1:k
		trainError(i) = frobRecon(Xtrain, F(1:i, :), Mutrain);
	end
	figure
	plot([1:k], trainError)
	title('Training Cost')
	ylabel('Cost')
	xlabel('Factors')

	reconError = zeros(k);
	for i = 1:k
		reconError(i) = frobRecon(Xtest, F(1:i, :), Mutest);
	end
	figure
	plot([1:k], reconError)
	title('Test Cost Relative to Deleted Data')
	ylabel('Cost')
	xlabel('Factors')

	origError = zeros(k);
	for i = 1:k
		origError(i) = frobReconOrig(Xtest_orig, Xtest, F(1:i, :), Mutest);
	end
	figure
	plot([1:k], origError)
	title('Test Cost Relative to Original Data')
	ylabel('Cost')
	xlabel('Factors')

	allError = zeros(k);
	for i = 1:k
		allError(i) = frobReconOrig(X, Xall, F(1:i, :), Muall);
	end
	figure
	plot([1:k], allError)
	title('Cost of All Data (Missing Values) Relative to Original Data')
	ylabel('Cost')
	xlabel('Factors')
end

	% Reconstruct
	% X_hat = P*F + Mu;

function [val] = frobOrig(X, Xhat)
	A = Xhat - X;
	val = norm(A,'fro');
end

function [val] = frobRecon(X, F, Mu)
	Xrecon = (X - Mu) * pinv(F) * F + Mu;
	val = frobOrig(Xrecon, X);
end

function [val] = frobReconOrig(Xhat, X, F, Mu)
	Xrecon = (X - Mu) * pinv(F) * F + Mu;
	val = frobOrig(Xrecon, Xhat);
end
