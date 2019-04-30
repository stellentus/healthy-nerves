function [names] = canonicalNamesNoTE20()
	names = [
		"Stimulus (mA) for 50% max response",   % 1
		"Strength-duration time constant (ms)", % 2
		"Rheobase (mA)",
		"Stimulus-response slope",
		"Peak response (mv)",           % 5
		"Resting I/V slope",
		"Minimum I/V slope",
		"Temperature ( C)",
		"RRP (ms)",
		"TEh(90-100ms)",                % 10
		"TEd(10-20ms)",                 % 11
		"Superexcitability (%)",        % 12
		"Subexcitability (%)",          % 13
		"Age (years)",                  % 14
		"Sex (M=1, F=2)",               % 15
		"Latency (ms)",
		"TEd(40-60ms)",
		"TEd(90-100ms)",                % 18
		"TEh(10-20ms)",
		"TEd(undershoot)",              % 20
		"TEh(overshoot)",               % 21
		"TEd(peak)",
		"S2 accommodation",
		"Accommodation half-time (ms)",
		"Hyperpol. I/V slope",          % 25
		"Refractoriness at 2.5ms (%)",
		"TEh(20-40ms)",
		"TEh(slope 101-140ms)",
		"Refractoriness at 2 ms (%)",
		"Superexcitability at 7 ms (%)",% 30
		"Superexcitability at 5 ms (%)",
	];
end
