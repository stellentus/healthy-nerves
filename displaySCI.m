%displaySCI displays a 2D plot with SCI results
figure;

files = struct('ref', 'median', 'proj', 'cp', 'sci', 'medianSCI');
if evalin( 'base', 'exist(''nerve'',''var'') == 1' ) && strcmp(nerve, 'cp')
	files = struct('ref', 'cp', 'proj', 'median', 'sci', 'cpSCI');
end

[valuesRef, participantsRef, measures] = loadData(files.ref, true);
[valuesProj, participantsProj] = loadData(files.proj, true);

coefforthRef = lineCross(valuesRef, valuesProj, participantsRef, participantsProj);

[valuesSCI] = loadData(files.sci, true);
scoreSCI = zscore(valuesSCI)*coefforthRef;

plot(scoreSCI(:,1:2), 'xk');
