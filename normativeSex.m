%% normativeSex: Determine sex effects in normative data.
function [mMean, fMean, pvals] = normativeSex(plotFigs, values)
	if nargin < 2
		load("bin/batch-normative.mat");
		values = [canValues; japValues; porValues];
	end
	if nargin < 1
		plotFigs = false;
	end

	[isLin, isLog, adVal, skew] = normativeDistributions(values, measures);

	sexIndex = 15;
	males = values(values(:,sexIndex) == 1, :);
	females = values(values(:,sexIndex) == 2, :);
	if size(males, 1) + size(females, 1) ~= size(values, 1)
		error("Could not split males and females")
	end
	[isLinM, isLogM, adValM, skewM] = normativeDistributions(males, measures);
	[isLinF, isLogF, adValF, skewF] = normativeDistributions(females, measures);

	addpath lib
	close all;

	numMeasures = length(measures);
	pvals = zeros(1, numMeasures);
	mAvg = zeros(1, numMeasures);
	fAvg = zeros(1, numMeasures);
	mStd = zeros(1, numMeasures);
	fStd = zeros(1, numMeasures);
	fprintf("ID | isLin | isLog | Anderson-Darling  | Skewness (M/F/Both)  | Distr. Type and Effect Size | p-val | Measure Name\n");
	fprintf("-- | ----- | ----- | ----------------- | -------------------- | --------------------------- | ----- | ------------------------------------\n");
	for i=1:numMeasures
		if i == sexIndex
			continue;
		end

		mVal = males(:, i);
		fVal = females(:, i);

		if isLinM(i) && isLinF(i)
			% It might be both, but then we still pick linear/gaussian.
			distrType = "gaussian";
			[~,pv] = ttest2(mVal, fVal);
			mAvg(i) = mean(mVal);
			fAvg(i) = mean(fVal);
			mStd(i) = std(mVal);
			fStd(i) = std(fVal);
		elseif isLogM(i) && isLogF(i)
			distrType = "log-norm";
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
			distrType = "non-para";
			[~,pv] = ranksum(mVal, fVal);
			mAvg(i) = median(mVal);
			fAvg(i) = median(fVal);
		end
		pvals(i) = pv;

		if nargout == 0
			if pv < 0.001
				effectType = "has a large";
			elseif pv < 0.01
				effectType = "has a small";
			elseif pv < 0.05
				effectType = "may have an";
			else
				effectType = "has no sig.";
			end

			fprintf("%02d | %d %d %d | %d %d %d | %.3f %.3f %.3f | %+.3f %+.3f %+.3f | %s %s effect | %.3f | %s\n", i, isLinM(i), isLinF(i), isLin(i), isLogM(i), isLogF(i), isLog(i), adValM(i), adValF(i), adVal(i), skewM(i), skewF(i), skew(i), distrType, effectType, pv, measures(i))
			% fprintf("\\textbf{%s} & HYPOTH & %d & %.5f & %s & %.3f, %.3f & %.3f, %.3f \\\\\n", measures(i), fAvg(i) > mAvg(i), pv, distrType, adValM(i), adValF(i), skewM(i), skewF(i)) % This is for printing into LaTeX

			if plotFigs
				fig = figure('Position', [10 10 900 600]);
				violin({mVal, fVal});
				title(sprintf("%d: %s %s effect\np=%.3f, assuming %s distribution (AD %.3f and skew %.3f)", i, measures(i), effectType, pv, distrType, adVal(i), skew(i)));
			end
		end
	end

	rmpath lib
end

3, 24, 21,
