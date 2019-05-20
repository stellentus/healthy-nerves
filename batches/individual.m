% List indices in order of lowest to highest BVI.
function individual()
	plotAll = false;
	if nargin < 1
		plotAll = true;
		figToPlot = '';
	end

	iters = 30;
	sampleFraction = 0.8;

	% Load the data
	filepath = "bin/batch-normative.mat";
	load(filepath);
	clear nanMethod;

	% Create a combined vector for labels (with all datasets) and one for values
	labels = [ones(canNum, 1); ones(japNum, 1) * 2; repmat(3, porNum, 1)];
	values = [canValues; japValues; porValues];

	ba = BatchAnalyzer("Normative Data", 3, values, labels, 'iters', iters, 'sampleFraction', sampleFraction);
	calculateBatch(ba);
	bas = [ba];

	for i=1:length(measures)
		ba = BACopyWithValues(ba, measures(i), values(:,i));
		calculateBatch(ba);
		bas = [bas ba];
	end

	% Sort with increasing homogeneity
	[~, ind] = sort([bas.Homogeneity_mean]);
	bas = bas(ind);

	plotBas(bas, 'individuals', 'Effects in Individual Measures');
end

%%%%%%%%%%%%%%%%%%%% RESULTS %%%%%%%%%%%%%%%%%%%%

% ## thresholdElectrotonus

% TEd(10–20ms)
% TEd(90–100ms)
% TEd(peak)
% TEh(10–20ms)
% TEd(undershoot)
% TEh(90–100ms)
% TEh(20–40ms)
% TEh(slope 101–140ms)
% Accommodation half-time (ms)
% TEd(40–60ms)
% TEh(overshoot)
% S2 accommodation

% ## recoveryCycle

% Refractoriness at 2 ms (%)
% Refractoriness at 2.5ms (%)
% RRP (ms)
% Subexcitability (%)
% Superexcitability at 5 ms (%)
% Superexcitability (%)
% Superexcitability at 7 ms (%)

% ## chargeDuration

% Rheobase (mA)
% Strength-duration time constant (ms)

% ## thresholdIV

% Resting I/V slope
% Hyperpolarization I/V slope
% Minimum I/V slope

% ## stimulusResponse

% Peak response (mV)
% Stimulus (mA) for 50% max response
% Stimulus-response slope

% ## other

% Temperature (C)
% Age (years)
% Latency (ms)
% Sex
