% stdDist determines how far a point is from the mean
% dim is the number of measures
function stdDist(dim, score, participants, printData)
	len = dot(score, score, 2); % a column vector holding the length of each point
	probability = chi2cdf(len, dim);

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

	if nargin > 3 && printData
		disp([participants sForP len probability]);
	end
	histogram(sForP);
end

function stds = getSTD()
	stds = [1:10]; % Make it length 5
	for s = 1:length(stds)
		stds(s) = 2*normcdf(s)-1;
	end
end
