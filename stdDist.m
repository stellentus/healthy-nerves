% stdDist determines how far a point is from the mean
function stdDist(values, participants, alg)
	if nargin < 3
		alg = 'svd';
	end

	[coeff, score] = pca(values, 'VariableWeights', 'variance', 'algorithm', alg);

	len = dot(score, score, 2); % a column vector holding the length of each point
	probability = chi2cdf(len, length(coeff));

	stds = getSTD();
	sForP(1:length(participants), :) =  NaN;
	for i = 1:length(participants)
		for s = 1:length(stds)
			if probability(i) < stds(s)
				sForP(i) = s; % save the number of STDs this is from mean
				break
			end
		end
	end

	disp([participants sForP len probability]);
	histogram(sForP);
end

function stds = getSTD()
	stds = [1:10]; % Make it length 5
	for s = 1:length(stds)
		stds(s) = 2*normcdf(s)-1;
	end
end
