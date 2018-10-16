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

function plotdiagonals(sortdiagarmleg, sortdiagrandarmleg, sortedmeasures)
	% plot intra-individual differences and inter-individual differences
	x = 1:32;
	figure1 = figure(1);
	hold on;
	fontsize = 40;
	cohenfontsize = 28;
	linewidth = 8;
	plot(x, sortdiagarmleg, 'b', 'LineWidth', linewidth);
	plot(x, sortdiagrandarmleg, 'r', 'LineWidth', linewidth);
	legend({'Arm/Leg Correlation', 'Random Arm/Leg Correlation'}, 'FontSize', 30);
	xticks(x);
	xticklabels(sortedmeasures);
	set(gca, 'FontSize', fontsize, 'LineWidth', linewidth);
	xtickangle(60);
	ylabel('R^2 value', 'FontSize', fontsize);
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

	% add annotations for effect sizes
	annotation(figure1,'textbox',...
		[0.694949036700755 0.5004160483245339 0.176198830409357 0.0348214285714286],...
		'String','Small Correlational Difference',...
		'LineStyle','none',...
		'FontSize',cohenfontsize,...
		'FontName','Helvetica Neue');
	annotation(figure1,'textbox',...
		[0.694949036700755 0.623360115798504 0.17894736842105 0.0348214285714286],...
		'String','Medium Correlational Difference',...
		'LineStyle','none',...
		'FontSize',cohenfontsize,...
		'FontName','Helvetica Neue');
	annotation(figure1,'textbox',...
		[0.694949036700755 0.746396917538431 0.176616541353383 0.0348214285714286],...
		'String','Large Correlational Difference',...
		'LineStyle','none',...
		'FontSize',cohenfontsize,...
		'FontName','Helvetica Neue');
	hold off;
end
