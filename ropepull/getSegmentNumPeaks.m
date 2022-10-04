function numPeaks = getSegmentNumPeaks(trial, colName)
	if isfield(trial.(colName), 'data')
		data = trial.(colName).('data');
		assert(size(data,2)==1, 'Data should be 1-D');
		[pks, loc] = findpeaks(data);
		numPeaks = length(loc);
	else
		numPeaks = 0;
	end
