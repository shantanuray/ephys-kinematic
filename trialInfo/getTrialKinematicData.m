function trial = getTrialKinematicData(...
	aniposeData,...
	trialReachInfo,...
	eventData,...
	ephysInfo,...
	videoSamplingRate,...
	fixedReachIntervalms)
	% Segment kinematic Data based on trial reach segments
    %
    % emgData = getTrialKinematicData(aniposeData,...
	%									trialReachInfo,...
	%									videoSamplingRate,...
	%									fixedReachIntervalms)
    %
    % Inputs:
    %	- aniposeData: struct(), 3-D kinematic data for each body part stored as table (see importAnipose3dData)
    %	- trialReachInfo: struct(), trial reach segments
    %		- start_ts, start_idx: Time sample & kinematic data index for start of reach segment
	%		- end_ts_first: Time sample for end of first reach (such as first spout contact)
	%		- end_ts_last: Time sample for end of last reach, in case of multiple indicators (multiple spout contacts)
	%	- eventData: Event data (such as laser trig time samples)
	%	- ephysInfo: Ephys recording basic info
	%	- videoSamplingRate: Video sampling rate
	%		Default = 200 Hz
	%	- fixedReachIntervalms: Time interval from start of reach "fixed" time segment processing
	%		Default = 750 ms

	if nargin<4
		videoSamplingRate = 200;
	end
	if nargin<4
		fixedReachIntervalms = 750;
	end
	
	aniposeNumTS = round((fixedReachIntervalms/1000)*videoSamplingRate,0);
	ephysNumTS = round((fixedReachIntervalms/1000)*ephysInfo.samplingRate,0);
	if ~isnan(trialReachInfo.start_ts)
		% aniposeData and videoFrames_timestamps have the same # of total samples and are aligned with each other
		% trialReachInfo.start_idx is the index into videoFrames_timestamps and hence that can be used directly for aniposeData
		% i.e. index into videoFrames_timestamps is same as index into aniposedata
		trial.('kinematicData_fixedReachSegment') = aniposeData(trialReachInfo.start_idx:min(size(aniposeData, 1), trialReachInfo.start_idx+aniposeNumTS-1), :);
		trial.('lightOnTrig_ts_fixed') = intersect(start_ts:start_ts+ephysNumTS-1, eventData.lightOnTrig_ts);
		if isempty(trial.('lightOnTrig_ts_fixed'))
			trial.('lightTrig_fixed') = 'OFF';
		else
			trial.('lightTrig_fixed') = 'ON';
		end
		if ~isnan(trialReachInfo.end_ts_first) & (trialReachInfo.hitormiss==1)
			trial.('lightOnTrig_ts') = intersect(start_ts:end_ts_first, eventData.lightOnTrig_ts);
			if isempty(trial.('lightOnTrig_ts'))
				trial.('lightTrig') = 'OFF';
			else
				trial.('lightTrig') = 'ON';
			end
			% takes all the anipose data between each start and end index
			% Assumption: ephysNumTS is the same for index as well as time samples for fixed interval
			if trialReachInfo.end_idx_first<size(aniposeData, 1)
				trial.('kinematicData_firstReachSegment') = aniposeData(trialReachInfo.start_idx:trialReachInfo.end_idx_first, :);
				trial.('kinematicData_lastReachSegment') = aniposeData(trialReachInfo.start_idx:trialReachInfo.end_idx_last, :);
				
			else
				trial.('kinematicData_firstReachSegment') = [];
				trial.('kinematicData_lastReachSegment') = [];
			end
		else
			trial.('kinematicData_firstReachSegment') = [];
			trial.('kinematicData_lastReachSegment') = [];
		end
	end
end