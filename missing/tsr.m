% Code from Abel Folch-Fortuny, Francisco Arteaga, Alberto Ferrer (2015). PCA model building with missing data: new proposals and a comparative study. Chemometrics and Intelligent Laboratory Systems 146, pp. 77–88.

% Inputs:
% X: data matrix with NaNs for the missing data.
% A: number of principal components.

% Outputs:
% X: original data set with the imputed values.
% m: estimated mean vector of X.
% S: estimated covariance matrix of X.
% It: number of iterations.
% Xrec: PCA reconstruction of X with A components.

function [X,m,S,It,Xrec]=pcambtsr(X,A)
	[n,p]=size(X);
	for i=n:-1:1
		r=~isnan(X(i,:));
		pat(i).O=find(r==1); % observed variables
		pat(i).M=find(r==0); % missing variables
		pat(i).nO=size(pat(i).O,2); % number of observed variables
		pat(i).nM=size(pat(i).M,2); % number of missing variables
	end
	mis=isnan(X);
	[r c]=find(isnan(X));
	X(mis)=0;
	meanc=sum(X)./(n-sum(mis));
	for k=1:length(r),
		X(r(k),c(k))=meanc(c(k));
	end
	maxiter=5000;
	conv=1.0e-10;
	diff=100;
	It=0;
	while It<maxiter & diff>conv
		It=It+1;
		Xmis=X(mis);
		mX=mean(X);
		S=cov(X);
		Xc=X-ones(n,1)*mX;
		if n>p
			[U D V]=svd(Xc,0);
		else
			[V D U]=svd(Xc',0);
		end
		V=V(:,1:A);
		for i=1:n % for each row
			if pat(i).nM>0 % if there are missing values
				L=V(pat(i).O,1:min(A,pat(i).nO)); % L is the key matrix
				S11=S(pat(i).O,pat(i).O);
				S21=S(pat(i).M,pat(i).O);
				z1=Xc(i,pat(i).O)';
				z2=S21*L*pinv(L'*S11*L)*L'*z1;
				Xc(i,pat(i).M)=z2';
			end
		end
		X=Xc+ones(n,1)*mX;
		d=(X(mis)-Xmis).^2;
		diff=mean(d);
	end
	S=cov(X);
	m=mean(X);
	[u d v]=svd(S,0);
	P=v(:,1:A);
	T=(X-ones(n,1)*m)*P;
	Xrec=ones(n,1)*m+T*P';
end
