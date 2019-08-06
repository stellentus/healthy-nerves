function bv = bvi(x, y, nclust)
% Compute variation of information for batch effects between of two discrete clusterings x and y.
% It depends upon
%	variation of information: VI(x,y)=H(x)+H(y)-2I(x,y)
%	normalization by maximal variation of information: 2*log2(nclust)
%	inversion and shifting to scale from 0 (no batch effects) to 1 (completely clustered data, maximal batch effects)
%
% Input:
%   x, y: two integer vector of the same length
%   nclust: the maximum number of clusters in x or y
% Ouput:
%   bv: variation of information for batch effects: bv=1-(H(x)+H(y)-2I(x,y))/(2*log2(nclust))

% Makes use of voi, a variation of nmi, which was written by Mo Chen (sth4nth@gmail.com).
% The nmi code can be found at https://github.com/PRML/PRMLT/tree/master/chapter01
% To implement voi, copy nmi, but append the following two lines and return 'vi':
% MI = Hx + Hy - Hxy; % mutual information
% vi = Hx+Hy-2*MI; % variation of information

bv = 1-voi(x,y)/(2*log2(nclust));
