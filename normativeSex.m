%% normativeSex: Determine sex effects in normative data.
function [mMean, fMean, pvals] = normativeSex(values)
	if nargin == 0
		load("bin/batch-normative.mat");
		values = [canValues; japValues; porValues];
	end

	sexIndex = 15;

	[isLin, isLog] = normativeDistributions(values, measures);

	males = values(values(:,sexIndex) == 1, :);
	females = values(values(:,sexIndex) == 2, :);
	if size(males, 1) + size(females, 1) ~= size(values, 1)
		error("Could not split males and females")
	end

	numMeasures = length(measures);
	pvals = zeros(1, numMeasures);
	mAvg = zeros(1, numMeasures);
	fAvg = zeros(1, numMeasures);
	mStd = zeros(1, numMeasures);
	fStd = zeros(1, numMeasures);
	for i=1:numMeasures
		if i == sexIndex
			continue;
		end

		if isLin(i)
			[~,pv] = ttest2(males(:, i), females(:, i));
			mAvg(i) = mean(males(:, i));
			fAvg(i) = mean(females(:, i));
			mStd(i) = std(males(:, i));
			fStd(i) = std(females(:, i));
		elseif isLog(i)
			maleLog = log(abs(males(:, i)));
			femaleLog = log(abs(females(:, i)));
			[~,pv] = ttest2(maleLog, femaleLog);
			mAvg(i) = 10^mean(maleLog);
			fAvg(i) = 10^mean(femaleLog);
			mStd(i) = std(maleLog); % TODO: look up std for geometric mean
			fStd(i) = std(femaleLog);
			if values(1, i) < 0
				mAvg(i) = -mAvg(i);
				fAvg(i) = -fAvg(i);
			end
		else
			[~,pv] = ranksum(males(:, i), females(:, i));
			mAvg(i) = median(males(:, i));
			fAvg(i) = median(females(:, i));
		end
		pvals(i) = pv;

		if nargout == 0
			distrType = "NON";
			if isLin(i)
				% It might be both, but then we still pick linear.
				distrType = "LIN";
			elseif isLog(i)
				distrType = "LOG";
			end

			effectType = "NONE ";
			if pv < 0.001
				effectType = "LARGE";
			elseif pv < 0.01
				effectType = "SMALL";
			elseif pv < 0.05
				effectType = "MAYBE";
			end

			fprintf("%2d: (%s p=%.3f) %s %.3f (%.3f) vs %.3f (%.3f) for %s\n", i, effectType, pv, distrType, mAvg(i), mStd(i), fAvg(i), fStd(i), measures(i));
		end
	end
end
