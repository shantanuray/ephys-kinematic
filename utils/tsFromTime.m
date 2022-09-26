function tsSegment = tsFromTime(tSegment, retrieveDataFS)
	tsSegment = round(tSegment(1)*retrieveDataFS):round(tSegment(2)*retrieveDataFS);