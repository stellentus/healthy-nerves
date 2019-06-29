%% normativeDistributions: Test normative data to determine distribution types.
%
% This shows the results of different distribution types, based on the Anderson-Darling test.
%
% I've accepted LOG relationships for things that are slopes, but should slopes really be LOG?
% It's better than linear, but they're probably non-parametric.
%
%  1: OK, SR 			LOG (0.001 vs 0.733) for Stimulus (mA) for 50% max response
%  2: OK, slope		LOG (0.001 vs 0.244) for Strength-duration time constant (ms)
%  3: OK, slope 		LOG (0.001 vs 0.356) for Rheobase (mA)
%  4: Looks LOG slope, outliers	 NON (0.006 vs 0.034) for Stimulus-response slope
%  5: OK, positive	LIN (0.050 vs 0.001) for Peak response (mv)
%  6: OK, slope, poor	LOG (0.001 vs 0.357) for Resting I/V slope
%  7: OK, slope		LOG (0.006 vs 0.812) for Minimum I/V slope
%  8: OK, expected	NON (0.001 vs 0.001) for Temperature ( C)
%  9: OK, positive	NON (0.001 vs 0.011) for RRP (ms)
% 10: OK				LIN (0.335 vs 0.257) for TEh(90-100ms)
% 11: OK				LIN (0.352 vs 0.084) for TEd(10-20ms)
% 12: OK				LIN (0.236 vs 0.001) for Superexcitability (%)
% 13: ODD, expect LIN	NON (0.006 vs 0.001) for Subexcitability (%)
% 14: OK, expected	NON (0.001 vs 0.001) for Age (years)
% 15: OK, expected	NON (0.001 vs 0.001) for Sex (M=1, F=2)
% 16: ??				LOG (0.008 vs 0.711) for Latency (ms)
% 17: OK				LIN (0.921 vs 0.823) for TEd(40-60ms)
% 18: OK				LIN (0.104 vs 0.146) for TEd(90-100ms)
% 19: OK				LIN (0.375 vs 0.414) for TEh(10-20ms)
% 20: OK				LIN (0.776 vs 0.001) for TEd(undershoot)
% 21: ODD, expect LIN	NON (0.016 vs 0.001) for TEh(overshoot)
% 22: OK				LIN (0.843 vs 0.314) for TEd(peak)
% 23: OK				LIN (0.494 vs 0.002) for S2 accommodation
% 24: ODD, expect LIN?	LOG (0.002 vs 0.110) for Accommodation half-time (ms)
% 25: OK, slope		LOG (0.001 vs 0.054) for Hyperpol. I/V slope
% 26: OK, positive	NON (0.001 vs 0.001) for Refractoriness at 2.5ms (%)
% 27: OK				LIN (0.823 vs 0.474) for TEh(20-40ms)
% 28: ODD, slope expected	LIN (0.537 vs 0.044) for TEh(slope 101-140ms)
% 29: OK, positive	NON (0.001 vs 0.001) for Refractoriness at 2 ms (%)
% 30: OK				LIN (0.159 vs 0.001) for Superexcitability at 7 ms (%)
% 31: OK				LIN (0.221 vs 0.001) for Superexcitability at 5 ms (%)

function normativeDistributions()
	load("bin/batch-normative.mat");

	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	close all;
	warning('off', 'stats:adtest:OutOfRangePLow'); % I think this isn't important in this context.

	% TODO instead of adtest I should possibly use Pearson's sample skewness, since it's important to test for skew before doing t-test.
	% See https://stats.stackexchange.com/questions/25738/is-a-log-transformation-a-valid-technique-for-t-testing-non-normal-data

	for i=1:length(measures)
		figure();
		subplot(1,2,1);
		histogram(values(:,i), 30);
		title("Linear "+measures(i));
		[hlin, plin] = adtest(values(:,i));
		isLin = ~hlin;

		logVals = log(abs(values(:,i)));
		subplot(1,2,2);
		histogram(logVals, 30);
		title("Log "+measures(i));
		[hlog, plog] = adtest(logVals);
		isLog = ~hlog;

		distrType = "NON";
		if isLin
			% It might be both, but then we still pick linear.
			distrType = "LIN";
		elseif isLog
			distrType = "LOG";
		end

		fprintf("%2d: %s (%.3f vs %.3f) for %s\n", i, distrType, plin, plog, measures(i));
	end
end
