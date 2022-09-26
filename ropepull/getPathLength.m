function pathLength = getPathLength(trial,markerIndx)

	% pathLength = getPathLength(trial);
	xyz = getTrialXYZ(trial);
	% pathLength = Euclidean distance between consecutive points of a trial
	pathLength = sqrt(sum(diff(xyz,1,1).^2,3));
	padZerosCnt = length(xyz) - length(pathLength);
	% pad zero at start to make the # of rows the same as input trial data
	pathLength = padZeros(pathLength, padZerosCnt);
	if nargin==2
		pathLength = pathLength(:, markerIndx);
	end
