function [segmentPre, segmentPost] = getSegmentRhythymicPeak(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin)
	% segmentRhythymicPeak = getSegmentRhythymicPeak(trial, 'hand_left', 'x', 0);
	% segmentRhythymicPeak = getSegmentRhythymicPeak(trial, 'hand_left', 'x', 0, 'MinPeakProminence', .2);
	%
	% Ayesha: Write description
	[loc,pks,startPullLoc,endPullLoc] = getPeaks(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin{:});
	assert(length(pks)>=3, sprintf('Peak count = %d; Expected at least 3', length(pks)));
	medianLoc = loc-median(loc);
    refRhythmicPeak = find(medianLoc == min(medianLoc((medianLoc>0))));
	segmentPre = [loc(refRhythmicPeak-1),loc(refRhythmicPeak)]/getSamplingFrequency(trial);
	segmentPost = [loc(refRhythmicPeak),loc(refRhythmicPeak+1)]/getSamplingFrequency(trial);
