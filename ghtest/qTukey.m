function [x] = qTukey(v, k, p)
% QTUKEY Tukey's q studentized range critical value.
%    X = QTUKEY(V,K,P) finds the Tukey's q studentized range critical value.
% (This modified macro based on the Fortran77 algorithm AS 190.2 Appl. Statist. (1983)
% gives a very good approximation for 0.8 < p < 0.995).
%
%   Syntax: function x = qTukey(v,k,p)
%
%     Inputs:
% 	        v - sample degrees of freedom (must be the same for each sample).
% 	        k - number of samples.
% 	        p - cumulative probability value.
%
%  References:
%
%  Algorithm AS 190.2 (1983), Journal of Applied Statistics, 32(2)
%

	if nargin < 3
		p = 0.95;
	end

	if nargin < 2
	   error('Requires at least two arguments.');
	end

	t=norminv(.5 + .5 * p);
	vmax=120; c=[0.89, 0.237, 1.214, 1.21, 1.414];

	if v > vmax
		warning('The sample degrees of freedom (%d) is greater than %d, so the GHtest results are invalid.', v, vmax);
	end

	t = t + (t * t * t + t) / v / 4;
	q = c(1) - c(2) * t;
	q = q - c(3) / v + c(4) * t / v;
	qc = t * (q * log(k-1) + c(5));
	x = qc;
	x = x / sqrt(2);
end
