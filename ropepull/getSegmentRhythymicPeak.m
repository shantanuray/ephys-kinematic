function [segmentPre, segmentPost] = getSegmentRhythymicPeak(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin)
	% segmentRhythymicPeak = getSegmentRhythymicPeak(trial, 'hand_left', 'x', 0);
	% segmentRhythymicPeak = getSegmentRhythymicPeak(trial, 'hand_left', 'x', 0, 'MinPeakProminence', .2);
	%
	% Ayesha: Write description
	[loc,pks,startPullLoc,endPullLoc] = getPeaks(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin{:});

	if length(pks)>=3,
        medianLoc = loc-median(loc);
        refRhythmicPeak = find(medianLoc == min(medianLoc((medianLoc>=0))));
        segmentPre = [loc(refRhythmicPeak-1),loc(refRhythmicPeak)]/getSamplingFrequency(trial);
        segmentPost = [loc(refRhythmicPeak),loc(refRhythmicPeak+1)]/getSamplingFrequency(trial);
    else
        sprintf('getSegmentRhythymicPeak:%s:Peak count = %d; Expected at least 3', trial.trialName, length(pks));
        segmentPre = nan;
        segmentPost = nan;
    end
end
