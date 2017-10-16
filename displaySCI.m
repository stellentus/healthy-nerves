%displaySCI displays a 2D plot with SCI results
figure;

files = struct('ref', 'arm', 'proj', 'leg', 'sci', 'armSCI');
if evalin( 'base', 'exist(''nerve'',''var'') == 1' ) && strcmp(nerve, 'leg')
	files = struct('ref', 'leg', 'proj', 'arm', 'sci', 'legSCI');
end

addpath import;

[valuesRef, participantsRef] = loadData(files.ref, true);
[valuesProj, participantsProj] = loadData(files.proj, true);

addpath analyze;
coefforthRef = lineCross(valuesRef, valuesProj, participantsRef, participantsProj);
rmpath analyze;

[valuesSCI] = loadData(files.sci, true);
scoreSCI = zscore(valuesSCI)*coefforthRef;

plot(scoreSCI(:,1:2), 'xk');

rmpath import;
