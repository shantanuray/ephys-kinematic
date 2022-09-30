function numPeaks = getSegmentNumPeaks(trial, colName)
	data = trial.(colName).('data');
	assert(size(data,2)==1, 'Data should be 1-D');
	[pks, loc] = findpeaks(data);
	numPeaks = length(loc);