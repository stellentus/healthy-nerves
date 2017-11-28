% pathFor returns the path for the given data
function [pth] = pathFor(dataType)
	switch dataType
		case 'leg'
			pth = 'data/CPrepeatedmeasures.xlsx';

		case 'arm'
			pth = 'data/MedianRepeatedmeasures.xlsx';

		case 'legSCI'
			% Previously we used SCI_CP.xlsx
			pth = 'data/SCI_CP.xlsx';

		case 'armSCI'
			pth = 'data/All_MN_SCI.xlsx';

		otherwise
			pth = '';
	end
end
