function [firstPkSegment, firstPkLoc] = getSegmentFirstPeak(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin)
	% segmentFirstPeak = getSegmentFirstPeak(trial, 'hand_left', 'x', 0);
	% segmentFirstPeak = getSegmentFirstPeak(trial, 'hand_left', 'x', 0, 'MinPeakProminence', .2);
	%
	% Ayesha: Write description
	[loc,pks,startPullLoc,endPullLoc] = getPeaks(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin{:});
	assert(length(pks)>0, 'No peaks');
	firstPkLoc = loc(1);
	firstPkSegment = [startPullLoc,firstPkLoc]/getSamplingFrequency(trial);
