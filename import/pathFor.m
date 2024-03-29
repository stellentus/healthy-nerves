% pathFor returns the path for the given data
function [pth] = pathFor(dataType)
	switch dataType
		case 'leg'
			pth = 'data/human/CPrepeatedmeasures.xlsx'; % I'm not using the full set because QTRAC chokes on Excel import after around 130 rows

		case 'arm'
			pth = 'data/human/FESmedianAPB_Concatenated.xlsx';

		case 'legSCI'
			% Previously we used SCI_CP.xlsx
			pth = 'data/human/SCI_CP.xlsx';

		case 'armSCI'
			pth = 'data/human/All_MN_SCI.xlsx';

		otherwise
			pth = '';
	end
end
