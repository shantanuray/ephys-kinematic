function matchIdx = searchCellInCell(inCell, matchCell)
	matchIdx = []
	for idx = 1:length(matchCell)
		matchIdx = [matchIdx, searchStrInCell(inCell, matchCell{idx})];
	end