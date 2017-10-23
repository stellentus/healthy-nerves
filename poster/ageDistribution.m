% ageDistribution plots the age/sex distribution
function ageDistribution(age, sex, ageTotal, sexTotal)
	MALE = 1;
	FEMALE = 2;
	edges = [15:5:70];

	ageM = age(sex == MALE);
	ageF = age(sex == FEMALE);
	ageTotalM = ageTotal(sex == MALE);
	ageTotalF = ageTotal(sex == FEMALE);

	disp(edges);
	ageBinM = histcounts(ageM, edges);
	disp(ageBinM);
	ageBinF = histcounts(ageF, edges);
	disp(ageBinF);
	ageTotalBinM = histcounts(ageTotalM, edges);
	disp(ageTotalBinM);
	ageTotalBinF = histcounts(ageTotalF, edges);
	disp(ageTotalBinF);

	figure;
	hold on;
	barh(edges(1:end-1), ageTotalBinM, 'b', 'BarWidth', 1);
	barh(edges(1:end-1), -1*ageTotalBinF, 'b', 'BarWidth', 1);
	barh(edges(1:end-1), ageBinM, 'r', 'BarWidth', 1);
	barh(edges(1:end-1), -1*ageBinF, 'r', 'BarWidth', 1);
end
