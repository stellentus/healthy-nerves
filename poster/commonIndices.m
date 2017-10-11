% commonIndices finds the indices in common between the two lists
function [ind1, ind2] = commonIndices(participants1, participants2)
	ind1 = [];
	ind2 = [];

	p = 1;
	for i1 = 1:length(participants1)
		% Find the projection participant that matches this reference participant
		for i2 = p:length(participants2)
			if strcmp(participants1(i1), participants2(i2))
				p = i2;
				break;
			end
		end

		% Make sure a match was actually found before plotting
		if strcmp(participants1(i1), participants2(p))
			ind1 = [ind1 i1];
			ind2 = [ind2 i2];
		end
	end
end
