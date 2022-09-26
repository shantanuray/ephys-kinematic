function [pkSegment, pkLoc, firstMarker] = getFirstMarker(trial, markerNames, dorsoVentralAxis, maxPeakHeight, varargin)
	% findFirstMarker = getFirstMarker(trial, {'hand_left', 'hand_right'});
	assert(length(markerNames)==2, sprintf('getFirstMarker markerNames = %d Expected 2', length(markerNames)))
	pkSegments = {};
	pkLocs = [];
	for m = 1:length(markerNames)
		[pkSegments{m}, pkLocs(m)] = getSegmentFirstPeak(trial, markerNames{m}, dorsoVentralAxis, maxPeakHeight, varargin{:});
	end
	firstMarker = find(pkLocs==min(pkLocs));
	pkSegment = pkSegments{firstMarker};
	pkLoc = pkLocs(firstMarker);