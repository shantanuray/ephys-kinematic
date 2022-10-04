function tsSegment = tsFromTime(tSegment, retrieveDataFS)
    if ~isnan(tSegment)
	    tsSegment = round(tSegment(1)*retrieveDataFS):round(tSegment(2)*retrieveDataFS);
    else
        tsSegment = nan;
    end
end