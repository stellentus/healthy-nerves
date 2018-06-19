% lorenz creates images for the Lorenz paper
function lorenz()
	close all;

	addpath import;
	[SP_SOL, ~, measureNames] = mefimport('data/rat/RSOL all SP.xlsx', false, true);
	[SP_TA, ~] = mefimport('data/rat/RTA all SP.xlsx', false, true);
	[KX_SOL, ~] = mefimport('data/rat/SOL-KXpair.xlsx', false, true);
	[KX_TA, ~] = mefimport('data/rat/TA-KXpair.xlsx', false, true);
	rmpath import;

	% Set colors
	color_SP_TA = [hex2dec('2E') hex2dec('00') hex2dec('FD')]/255;
	color_KX_TA = [hex2dec('7F') hex2dec('00') hex2dec('80')]/255;
	color_SP_SOL = [hex2dec('FA') hex2dec('00') hex2dec('1D')]/255;
	color_KX_SOL = [hex2dec('FA') hex2dec('A7') hex2dec('1E')]/255;

	% Plot KX vs SP, refractory cycle only.
	thingsToPlot = {'TEh(90-100ms)', 'Superexcitability at 5 ms (%)', 'Subexcitability (%)'};
	colors_SOL = [color_SP_SOL; color_KX_SOL];
	colors_TA = [color_SP_TA; color_KX_TA];
	for k = 1:length(thingsToPlot)
		index = find(measureNames == thingsToPlot{k});

		plotTwo(SP_SOL(:, index), KX_SOL(:, index), {'SP', 'KX'}, colors_SOL, thingsToPlot{k}, sprintf('img/lorenz/SOL-%d.png', index), false);
		plotTwo(SP_TA(:, index), KX_TA(:, index), {'SP', 'KX'}, colors_TA, thingsToPlot{k}, sprintf('img/lorenz/TA-%d.png', index), false);
	end

	% Plot SOL vs TA, but only for SP.
	thingsToPlot = {'TEh(90-100ms)', 'Superexcitability at 5 ms (%)', 'Subexcitability (%)', 'Minimum I/V slope', '???'};
	colors_SP = [color_SP_TA; color_SP_SOL];
	for k = 1:length(thingsToPlot)
		index = find(measureNames == thingsToPlot{k});
		if isempty(index)
			fprintf('Could not plot missing thing %s\n', thingsToPlot{k});
			continue;
		end
		plotTwo(SP_TA(:, index), SP_SOL(:, index), {'TA', 'SOL'}, colors_SP, thingsToPlot{k}, sprintf('img/lorenz/SP-%d.png', index), true);
	end
end

function plotTwo(data1, data2, labels, colors, titlename, filename, paired)
	figure('rend', 'painters', 'pos', [10 10 450 600]);
	UnivarScatter(padcat(data1, data2), 'Label', labels, 'MarkerEdgeColor', colors, 'MarkerFaceColor', colors, 'PointSize', 132, 'WhiskWidthRatio', 1.3);
	set(gca,'box','off');
	set(gca,'FontSize', 32);
	set(gca,'FontWeight','bold');
	if strcmp(titlename, 'Superexcitability at 5 ms (%)')
		title('Superexcitability, 5ms(%)', 'FontSize', 28);
	else
		title(titlename, 'FontSize', 32);
	end
	xlim([.5, 2.5]);

	if paired
		[h, p] = ttest(data1, data2);
	else
		[h, p] = ttest2(data1, data2);
	end

	if h
		text(0.5, 0.9, '*', 'Units', 'normalized', 'FontSize', 64, 'HorizontalAlignment', 'center');
	else
		text(0.5, 0.9, 'n.s.', 'Units', 'normalized', 'FontSize', 26, 'HorizontalAlignment', 'center');
	end

	saveTightFigure(gcf, filename);
	close;
end
