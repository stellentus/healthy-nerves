% pathFor returns the path for the given data
function [pth] = pathFor(dataType)
	switch dataType
		case 'leg'
			pth = 'human/data/CPrepeatedmeasures.xlsx';

		case 'arm'
			pth = 'human/data/MedianRepeatedmeasures.xlsx';

		case 'legSCI'
			% Previously we used SCI_CP.xlsx
			pth = 'human/data/SCI_CP.xlsx';

		case 'armSCI'
			pth = 'human/data/All_MN_SCI.xlsx';

		otherwise
			pth = '';
	end
end
