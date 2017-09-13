% stats confirms the MEF stats match what Matlab calculates
function stats(data, stats, names)
	compare(names, stats.average, mean(data, 2, 'omitnan'), 'an average');
	compare(names, stats.SD, std(data, 0, 2, 'omitnan'), 'a standard deviation');
	compare(names, stats.SE, std(data, 0, 2, 'omitnan')./sqrt(stats.count), 'a standard error');
end

function compare(names, expected, actual, statName)
	for i = 1:length(actual)
		if abs(actual(i)-expected(i)) > 1e4*eps(min(abs(actual(i)),abs(expected(i))))
			disp('"' + names(i) + '" has ' + statName + ' of ' + actual(i) + ' instead of ' + expected(i) + '.');
		end
	end
end
