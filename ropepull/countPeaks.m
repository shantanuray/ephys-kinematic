function [num_pks, freq_pks] = countPeaks(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin)
	% [num_pks, freq_pks] = countPeaks(trial, markerName, dorsoVentralAxis, maxPeakHeight);
	% num_pks = # of peaks in trial
	% freq_pks = num_pks/t
	% t = duration of pulling action (not necessarily the entire trial)
	loc = getPeaks(trial, markerName, dorsoVentralAxis, maxPeakHeight, varargin{:});
	if ~isempty(loc)
		t = (loc(end)-loc(1))/trial.video_fps;
		num_pks = length(loc);
		freq_pks = num_pks/t;
	else
		num_pks = nan;
		freq_pks = nan;
	end
end