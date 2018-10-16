% corrArmLeg creates figures correlating arms and legs.
% Much of this code is modified from Davina's summer work.
function [sortdiagarmleg, sortdiagrandarmleg, sortedmeasures] = corrArmLeg(cData, mData, measures)
	% calculate intra-individual correlations
	armlegcorr = corr(cData, mData).^2;

	% calculate inter-individual correlations
	[randarmleg] = averageshuffledrho(cData, mData);
	clear cData mData;

	% only keep correlation between same measures
	[sortdiagarmleg, sortdiagrandarmleg, sortedmeasures] = savediagonals(armlegcorr, randarmleg, measures);
	clear measures armlegcorr randarmleg;

	% remove sex, age, and temperature parameters
	[sortdiagarmleg, sortdiagrandarmleg, sortedmeasures] = removeParams(sortdiagarmleg, sortdiagrandarmleg, sortedmeasures);

	% shorten names of some measures
	sortedmeasures = shortenNames(sortedmeasures);

	% plot correlations, threshold for size of differences, and appropriate labels
	plotdiagonals(sortdiagarmleg, sortdiagrandarmleg, sortedmeasures);
end

function [randarmleg] = averageshuffledrho(cData, mData)
	numLoops = 30; % you might need to loop more times later; this value is arbitrary right now
	allshuffledrho = zeros(35, 35, numLoops);
	for i = 1:numLoops
		mDatashuffled = mData(randperm(size(mData, 1)),:);
		rhoshuffle = corr(cData, mDatashuffled);
		allshuffledrho(:, :, i) = rhoshuffle.^2;
	end
	randarmleg = mean(allshuffledrho,3);
end

function[sortdiagarmleg, sortdiagrandarmleg, sortedmeasures] = savediagonals(armlegcorr, randarmleg, measures)
	% Calculate and store the square of correlation matrix diagonals (R2)
	diagarmleg = diag(armlegcorr);
	diagrandarmleg = diag(randarmleg);

	% Sort armlegocrr R2 diagonal in descending order and display randomcorr using
	% the same order of indices
	[sortdiagarmleg, indices] = sort(diagarmleg, 'descend');
	sortdiagrandarmleg = diagrandarmleg(indices);
	sortedmeasures = measures(indices);
end

function [cor, corRand, meas] = removeParams(cor, corRand, meas)
	sexStr = 'Sex (M=1, F=2)';
	ageStr = 'Age (years)';
	tempStr = 'Temperature ( C)';
	idx = [find(strcmp(meas, sexStr)) find(strcmp(meas, ageStr)) find(strcmp(meas, tempStr))];
	cor(idx) = [];
	corRand(idx) = [];
	meas(idx) = [];
end

function [meas] = shortenNames(meas)
	meas(find(strcmp(meas, 'TEh(overshoot)'))) = 'TEh(overshoot)';
	meas(find(strcmp(meas, 'TEd(90-100ms)'))) = 'TEd(90-100ms)';
	meas(find(strcmp(meas, 'Resting I/V slope'))) = 'Resting I/V';
	meas(find(strcmp(meas, 'TEd20(peak)'))) = 'TEd20(peak)';
	meas(find(strcmp(meas, 'Superexcitability at 5 ms (%)'))) = 'Superexcitability, 5ms';
	meas(find(strcmp(meas, 'TEd40(Accom)'))) = 'TEd40(Accom)';
	meas(find(strcmp(meas, 'Superexcitability at 7 ms (%)'))) = 'Superexcitability, 7ms';
	meas(find(strcmp(meas, 'TEh(90-100ms)'))) = 'TEh(90-100ms)';
	meas(find(strcmp(meas, 'S2 accommodation'))) = 'S2 accom.';
	meas(find(strcmp(meas, 'RRP (ms)'))) = 'RRP (ms)';
	meas(find(strcmp(meas, 'Superexcitability (%)'))) = 'Superexcitability';
	meas(find(strcmp(meas, 'Refractoriness at 2 ms (%)'))) = 'Refractoriness, 2ms';
	meas(find(strcmp(meas, 'TEd(peak)'))) = 'TEd(peak)';
	meas(find(strcmp(meas, 'TEd(undershoot)'))) = 'TEd(undershoot)';
	meas(find(strcmp(meas, 'TEd(40-60ms)'))) = 'TEd(40-60ms)';
	meas(find(strcmp(meas, 'TEd20(10-20ms)'))) = 'TEd20(10-20ms)';
	meas(find(strcmp(meas, 'Strength-duration time constant (ms)'))) = 'SDTC';
	meas(find(strcmp(meas, 'Peak response (mv)'))) = 'Peak response (mv)';
	meas(find(strcmp(meas, 'TEd(10-20ms)'))) = 'TEd(10-20ms)';
	meas(find(strcmp(meas, 'TEh(20-40ms)'))) = 'TEh(20-40ms)';
	meas(find(strcmp(meas, 'Refractoriness at 2.5ms (%)'))) = 'Refractoriness, 2.5ms';
	meas(find(strcmp(meas, 'TEh(slope 101-140ms)'))) = 'TEh(slope)';
	meas(find(strcmp(meas, 'TEh(10-20ms)'))) = 'TEh(10-20ms)';
	meas(find(strcmp(meas, 'Subexcitability (%)'))) = 'Subexcitability';
	meas(find(strcmp(meas, 'Minimum I/V slope'))) = 'Min I/V slope';
	meas(find(strcmp(meas, 'TEh20(10-20ms)'))) = 'TEh20(10-20ms)';
	meas(find(strcmp(meas, 'Accommodation half-time (ms)'))) = 'Accom. 1/2 time';
	meas(find(strcmp(meas, 'Stimulus-response slope'))) = 'Stim. slope';
	meas(find(strcmp(meas, 'Rheobase (mA)'))) = 'Rheobase (mA)';
	meas(find(strcmp(meas, 'Stimulus (mA) for 50% max response'))) = 'Stimulus for 50%';
	meas(find(strcmp(meas, 'Hyperpol. I/V slope'))) = 'Hyperpol. I/V slope';
	meas(find(strcmp(meas, 'Latency (ms)'))) = 'Latency (ms)';
end

function plotdiagonals(sortdiagarmleg, sortdiagrandarmleg, sortedmeasures)
	greenColor = [0.03529411764705882353, 0.38039215686274509804, 0.2];
	yellowColor = [0.98039215686274509804 0.8509803921568627451 0.25882352941176470588];

	ax = gca;
	ax.YColor = greenColor;
	ax.XColor = greenColor;

	% plot intra-individual differences and inter-individual differences
	x = 1:32;
	figure1 = figure(1);
	hold on;
	fontsize = 40;
	cohenfontsize = 28;
	linewidth = 8;
	hcor = plot(x, sortdiagarmleg, 'b', 'LineWidth', linewidth, 'Color', greenColor);
	hcorRand = plot(x, sortdiagrandarmleg, 'r', 'LineWidth', linewidth, 'Color', yellowColor);
	xticks(x);
	xticklabels(sortedmeasures);
	set(gca, 'FontSize', fontsize, 'LineWidth', linewidth);
	xtickangle(60);
	ylabel('R^2 value', 'FontSize', fontsize, 'Color', greenColor);
	set(gca, 'FontSize', fontsize, 'LineWidth', linewidth);

	% plot threshold lines
	x_dimensions = 32;
	small_threshold = zeros(1, x_dimensions);
	small_threshold(:) = 0.01;
	plot(x, small_threshold, '--k')
	medium_threshold = zeros(1, x_dimensions);
	medium_threshold(:) = 0.09;
	plot(x, medium_threshold, '--k')
	large_threshold = zeros(1, x_dimensions);
	large_threshold(:) = 0.25;
	plot(x, large_threshold, '--k');

	legend([hcor hcorRand], {'\color[rgb]{0.03529411764705882353, 0.38039215686274509804, 0.2} Arm/Leg Correlation', '\color[rgb]{0.98039215686274509804 0.8509803921568627451 0.25882352941176470588} Random Arm/Leg Correlation'}, 'FontSize', 30);
	legend boxoff;

	hold off;
end
