% Code from https://www.researchgate.net/post/I_am_looking_for_a_Matlab_code_for_Multiple_imputation_method_for_missing_data_analysis_can_anybody_help_me
% The code can be referenced as:
% 	Abel Folch-Fortuny, Francisco Arteaga, Alberto Ferrer (2015). PCA model building with missing data: new proposals and a comparative study. Chemometrics and Intelligent Laboratory Systems 146, pp. 77–88.

% X is a data matrix with NaN in the missing data
% M is the number of independent chains (we use M=10)
% CL is the len of each chain (we use CL=100)
%
% DAm:  estim. means for the M chains in M rows
% DAS:  estim. Cov. matrices for the M chains DAS(1).co, ..., DAS(M).co
% mest: estimated means (mest=mean(DAm))
% Sest: estimated covariance matrix (averaging DAS(1).co, ..., DAS(M).co)
% Y:    X with imputation made
%
function [DAm,DAS,mest,Sest,Y]=mi(X,M,CL)
	[n,p]=size(X);
	for i=n:-1:1,
		r=~isnan(X(i,:));
		% pat(i).O: the nO observed variables (subset of {1,2,...,p})
		pat(i).O=find(r==1);
		% pat(i).M: the nM missing variables (subset of {1,2,...,p})
		pat(i).M=find(r==0);
		% pat(i).nO and pat(i).nM are the size of pat(i).O and pat(i).M
		pat(i).nO=size(pat(i).O,2); % #{pat(i).O}
		pat(i).nM=size(pat(i).M,2); % #{pat(i).M}
	end

	mis=isnan(X);           % mis are the positions of the md in X
	[r c]=find(isnan(X));   % r and c store the row and column for all the md
	X(mis)=0;               % fill in the md with 0's
	meanc=sum(X)./(n-sum(mis)); % average of the known values for each column
	for k=1:length(r),
		X(r(k),c(k))=meanc(c(k)); % fill in each md with the mean of its column
	end

	mini=mean(X); Sini=cov(X);  % initial mean vector an covariance matrix
	DAm=zeros(M,p);              % contendrá las M medias en M filas
	for run=1:M,
		S=Sini;
		m=mini;
		for It=1:CL,
			for i=1:n,              % for each row
				if pat(i).nM>0,           % if there are missing values
					m1=m(1,pat(i).O)';           % nOx1
					m2=m(1,pat(i).M)';           % nMx1
					S11=S(pat(i).O,pat(i).O);    % nOxnO
					S12=S(pat(i).O,pat(i).M);    % nOx1
					z1=X(i,pat(i).O)';           % nOx1
					z2=m2+S12'*pinv(S11)*(z1-m1);% nMx1
					X(i,pat(i).M)=z2';           % 1xp
				end
			end
			m=mean(X);
			S=cov(X);
			[m,S]=DrawPost(m,S,10*n*n);
		end
		DAm(run,:)=m;
		DAS(run).co=S;
	end

	mest=mean(DAm);
	Sest=zeros(p,p);
	for k=1:M,
		Sest=Sest+DAS(k).co;
	end
	Sest=Sest/M;

	% Applies stochastic regression with the posterior of the mean (mest)
	% and the covariance matrix (Sest)
	for i=1:n,            % for each row
		if pat(i).nM>0,     % if there are missing values
			m1=mest(1,pat(i).O)';          % nOx1
			m2=mest(1,pat(i).M)';          % nMx1
			S11=Sest(pat(i).O,pat(i).O);   % nOxnO
			S12=Sest(pat(i).O,pat(i).M);   % nOxnM
			z1=X(i,pat(i).O)';             % nOx1
			z2=m2+S12'*pinv(S11)*(z1-m1);  %nMx1
			X(i,pat(i).M)=z2';  % fill in the md positions of row i
		end
	end

	Y=X;
end

function [mpost,Spost]=DrawPost(m,S,n)
	d=chol(S/n);
	p=size(S,1);
	if n<=81+p,
		x=randn(n-1,p)*d;
	else
		a=diag(sqrt(chi2rnd(n-(0:p-1))));
		for i=1:p-1,
			for j=i+1:p,
				a(i,j)=randn(1,1);
			end
		end
		x=a*d;
	end

	Spost=x'*x;
	mpost=(m'+chol(Spost/(n-1))*randn(size(S,1),1))';
end
