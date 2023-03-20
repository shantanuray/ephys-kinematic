function reachInfo = getReachesSpoutContact(oebin_file, startTrialTriggerLabel, kinNumSamples, fixedReachIntervalms, videoSamplingRate)
	% Get reach segments based on start trigger event (such as tone_on) and reach indicator such as spout contact
	% reachInfo = getReachesSpoutContact(oebin_file, startTrialTriggerLabel, fixedReachIntervalms)
	% Inputs:
	%	- oebin_file: ephys recording with kinematic event information
	%	- startTrialTriggerLabel: Start trigger label ("tone_on" or "solenoid_on")
	%	- kinNumSamples: Number of kinematic samples available (from aniposeData)
	%	- fixedReachIntervalms: Fixed reach time interval in ms
	%		Default = 750 ms
	%	- videoSamplingRate: Default 200 Hz
	% Outputs:
	% 	reachInfo: struct() with reach timing information with respect to startTrialTrigger
	%		- start_ts: contData.Timestamp value of start of trial
	%		- start_idx: Index into contData.Timestamp; Also, index into aniposeData (row number)
	%		- end_ts_first, end_ts_last: contData.Timestamp value of first and last spout contact of trial (end of trial)
	%		- end_ts_idx, end_ts_idx: Index into contData.Timestamp and aniposeData for first and last spout contact of trial

	% Assumptions:
	% 	spoutContact_first is wrt eventData.Timestamps
	% 	videoFrames.timestamps is wrt contData.Timestamps
	% 	contData.Timestamps is superset of eventData.Timestamps
	% 	There may or may not be an exact match of videoFrames.timestamps with spoutContact_first
	% 	Hence, This code identifies the frame timestamps that correspond to the start and end of each trial,
	% 	note video frame timestamps do not exactly correspond to openEphys timestamps because of videos are
	% 	sampled at 200fps every 50ms of openEphys data

	if nargin < 4
		fixedReachIntervalms = 750;
	end
	if nargin < 5
		videoSamplingRate = 200;
	end

	% Note: Passing oebin_file instead of raw data (esp. contData) because MATLAB seems to be passing by value and then not releasing memory
    % Loading it within the functon seems to be optimizing the memory consumption for raw data
    % contData has recordings for entire time period over several channels and floating point data, hence is quite large

	% Get ephys recording basic info
    ephysInfo = getEphysRecordingInfo(oebin_file);

    % Read event data from ephys
    eventData = getEventDataFromEphys(oebin_file);

    % Get and Sync video timeline to kinematic data
    videoFrames = getVideoTimeline(oebin_file, ephysInfo, kinNumSamples, videoSamplingRate);

    startTrialTrigger = eventData.(startTrialTriggerLabel);

	% Get First and all spout contact immediately after each start event (solenoid_on) and before next start event
	[spoutContact_first, spoutContact_multi, reachInfo.hitormiss, reachInfo.perchOnStart] = getSpoutContact(startTrialTrigger, eventData, ephysInfo);

	reachInfo.(startTrialTriggerLabel) = startTrialTrigger;
	% start ts is in terms of videoFrames.timestamps
	% start_idx is the index into videoFrames.timestamps
	reachInfo.start_ts = repmat(nan, length(startTrialTrigger), 1);
	reachInfo.start_idx = repmat(nan, length(startTrialTrigger), 1);
	for i = 1:length(startTrialTrigger) % starts a for loop which will cycle through all the values in startTrialTrigger
		tmp_indx1 = find(videoFrames.timestamps<=startTrialTrigger(i));%looks for all the frame timestamps that happen before the solenoid on value
		if ~isempty(tmp_indx1)
			reachInfo.start_ts(i) = videoFrames.timestamps(tmp_indx1(end));%selects the last one, this is the closest frame timestamp value to the solenoid on value
			reachInfo.start_idx(i) = tmp_indx1(end);
		end
	end
	reachInfo.end_ts_first = repmat(nan, length(spoutContact_first), 1);
	reachInfo.end_idx_first = repmat(nan, length(spoutContact_first), 1);
	reachInfo.end_ts_last = repmat(nan, length(spoutContact_first), 1);
	reachInfo.end_idx_last = repmat(nan, length(spoutContact_first), 1);
	for j=1:length(spoutContact_first)
		sc_indx_trial = nan;
		if ~isnan(spoutContact_first(j))
			%looks for all the frame timestamps that happen after the first spout contact on value
			sc_indx_trial = find(videoFrames.timestamps>=spoutContact_first(j));
		end
		
		if ~(isnan(sc_indx_trial) & isempty(sc_indx_trial)) & hitormiss(j)==1
			% Get time stamp value and index of end of first spout contact
			%selects the first value of the time stamp, this is the closest frame timestamp to the first spout contact on value 
			reachInfo.end_ts_first(j) = videoFrames.timestamps(sc_indx_trial(1));
			reachInfo.end_idx_first(j) = sc_indx_trial(1);

			%looks for all the frame timestamps that happen after the first spout contact uptil the last spout contact before next solenoid on
			last_sc_indx_trial = find(videoFrames.timestamps(sc_indx_trial)<=spoutContact_multi{j}(end));
			% In case there is only one spout contact, use the first sc
			if isempty(last_sc_indx_trial)
				last_sc_indx_trial = 1;
			end
			%selects the first value of the time stamp, this is the closest frame timestamp to the resp. spout contact
			reachInfo.end_ts_last(j) = videoFrames.timestamps(sc_indx_trial(1)+last_sc_indx_trial(end)-1);
			reachInfo.end_idx_last(j) = sc_indx_trial(1)+last_sc_indx_trial(end)-1;
	end
end