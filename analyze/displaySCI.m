%displaySCI displays a 2D plot with SCI results
figure;

files = struct('ref', 'arm', 'proj', 'leg', 'sci', 'armSCI');
if evalin( 'base', 'exist(''nerve'',''var'') == 1' ) && strcmp(nerve, 'leg')
	files = struct('ref', 'leg', 'proj', 'arm', 'sci', 'legSCI');
end

[valuesRef, participantsRef] = loadData(files.ref, true);
[valuesProj, participantsProj] = loadData(files.proj, true);

coefforthRef = lineCross(valuesRef, valuesProj, participantsRef, participantsProj);

[valuesSCI] = loadData(files.sci, true);
scoreSCI = zscore(valuesSCI)*coefforthRef;

plot(scoreSCI(:,1:2), 'xk');
