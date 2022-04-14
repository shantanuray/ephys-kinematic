function [start_ts, start_idx,...
		  end_ts_first, end_idx_first,...
		  end_ts_last, end_idx_last] = getTrialEventInfo(startTrialTrigger, videoFrames_timestamps, hitormiss,...
		  												 spoutContact_on_first, spoutContact_on_multi)
	% [start_ts, start_idx,...
	%  end_ts_first, end_idx_first,..
	%  end_ts_last, end_idx_last] = getTrialEventInfo(startTrialTrigger, videoFrames_timestamps,...
	% 		  										  spoutContact_on_first, spoutContact_on_multi);
	% Inputs:
	%	- startTrialTrigger: solenoid_on or tone_on events - Marks the start of trial
	%	- videoFrames_timestamps: eventData.Timestamps during kinematic data video recording
	%	- spoutContact_on_first, spoutContact_on_multi: Spout contact events (see getSpoutContact.m)
	% Outputs:
	%	- start_ts: contData.Timestamp value of start of trial
	%	- start_idx: Index into contData.Timestamp; Also, index into aniposeData (row number)
	%	- end_ts_first/ end_ts_last: contData.Timestamp value of first and last spout contact of trial (end of trial)
	%	- end_ts_idx/ end_ts_idx: Index into contData.Timestamp and aniposeData for first and last spout contact of trial

	% Assumptions:
	% spoutContact_on_first is wrt eventData.Timestamps
	% videoFrames_timestamps is wrt contData.Timestamps
	% contData.Timestamps is superset of eventData.Timestamps
	% There may or may not be an exact match of videoFrames_timestamps with spoutContact_on_first
	% Hence, This code identifies the frame timestamps that correspond to the start and end of each trial,
	% note video frame timestamps do not exactly correspond to openEphys timestamps because of videos are
	% sampled at 200fps every 50ms of openEphys data

	% start ts is in terms of videoFrames_timestamps
	% start_idx is the index into videoFrames_timestamps
	start_ts = [];
	start_idx = [];
	for i = 1:length(startTrialTrigger) % starts a for loop which will cycle through all the values in startTrialTrigger
		tmp_indx1 = find(videoFrames_timestamps<=startTrialTrigger(i));%looks for all the frame timestamps that happen before the solenoid on value
		if isempty(tmp_indx1)
			start_ts = [start_ts; nan];
			start_idx = [start_idx; nan];
		else
			start_ts = [start_ts; videoFrames_timestamps(tmp_indx1(end))];%selects the last one, this is the closest frame timestamp value to the solenoid on value
			start_idx = [start_idx; tmp_indx1(end)];
		end
	end
	end_ts_first=[];
	end_idx_first=[];
	end_ts_last=[];
	end_idx_last=[];
	for j=1:length(spoutContact_on_first)
		sc_indx_trial = nan;
		if ~isnan(spoutContact_on_first(j))
			%looks for all the frame timestamps that happen after the first spout contact on value
			sc_indx_trial = find(videoFrames_timestamps>=spoutContact_on_first(j));
		end
		
		if ~(isnan(sc_indx_trial) & isempty(sc_indx_trial)) & hitormiss(j)==1
			% Get time stamp value and index of end of first spout contact
			%selects the first value of the time stamp, this is the closest frame timestamp to the first spout contact on value 
			end_ts_first = [end_ts_first; videoFrames_timestamps(sc_indx_trial(1))]; 
			end_idx_first = [end_idx_first; sc_indx_trial(1)];

			%looks for all the frame timestamps that happen after the first spout contact uptil the last spout contact before next solenoid on
			last_sc_indx_trial = find(videoFrames_timestamps(sc_indx_trial)<=spoutContact_on_multi{j}(end));
			% In case there is only one spout contact, use the first sc
			if isempty(last_sc_indx_trial)
				last_sc_indx_trial = 1;
			end
			%selects the first value of the time stamp, this is the closest frame timestamp to the resp. spout contact
			end_ts_last = [end_ts_last; videoFrames_timestamps(sc_indx_trial(1)+last_sc_indx_trial(end)-1)]; 
			end_idx_last = [end_idx_last; sc_indx_trial(1)+last_sc_indx_trial(end)-1];
		else
			% For no spout contact, init to nan
			end_ts_first = [end_ts_first; nan];
			end_idx_first = [end_idx_first; nan];
			end_ts_last = [end_ts_last; nan];
			end_idx_last = [end_idx_last; nan];
		end
	end
end