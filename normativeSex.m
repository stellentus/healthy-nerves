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

	addpath lib
	close all;

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

		mVal = males(:, i);
		fVal = females(:, i);

		if isLin(i)
			[~,pv] = ttest2(mVal, fVal);
			mAvg(i) = mean(mVal);
			fAvg(i) = mean(fVal);
			mStd(i) = std(mVal);
			fStd(i) = std(fVal);
		elseif isLog(i)
			maleLog = log(abs(mVal));
			femaleLog = log(abs(fVal));
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
			[~,pv] = ranksum(mVal, fVal);
			mAvg(i) = median(mVal);
			fAvg(i) = median(fVal);
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

			label = sprintf("%2d: (%s p=%.3f) %s %.3f (%.3f) vs %.3f (%.3f) for %s", i, effectType, pv, distrType, mAvg(i), mStd(i), fAvg(i), fStd(i), measures(i));
			fprintf("%s\n", label);

			fig = figure('Position', [10 10 900 600]);
			violin({mVal, fVal});
			title(label);
		end
	end

	rmpath lib
end
