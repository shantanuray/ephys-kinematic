function numPeaks = getSegmentNumPeaks(trial, colName)
	if isfield(trial.(colName), 'data')
		data = trial.(colName).('data');
        if ~isnan(data)
		    assert(size(data,2)==1, 'Data should be 1-D');
		    [~, loc] = findpeaks(data);
		    numPeaks = length(loc);
        else
            numPeaks = 0;
        end
	else
		numPeaks = 0;
	end
