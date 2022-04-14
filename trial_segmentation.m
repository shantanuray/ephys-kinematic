
function trial_list = trial_segmentation(aniposeData,...
										   solenoid_on,...
										   spoutContact_on,...
										   videoFrames_timestamps,...
										   laserTrig,...
										   EMG_biceps,...
										   EMG_triceps,...
										   EMG_ecu,...
										   EMG_trap,...
										   aniposeNumTS,...
										   ephysNumTS,...
										   contDataTimestamps,...
										   eventDataTimestamps)
% trial_list = trial_segmentation(aniposeData,...
		% 						   solenoid_on,...
		% 						   spoutContact_on,...
		% 						   videoFrames_timestamps,...
		% 						   laserTrig,...
		% 						   EMG_biceps,...
		% 						   EMG_triceps,...
		% 						   EMG_ecu,...
		% 						   EMG_trap,...
		%						   aniposeNumTS,...
		%						   ephysNumTS);
%Output:
% ----------------
% 	trial_list: struct array with fields:
%			For (1) first spout contact (_first)
%				(2) last spout contact  (_last)
%				(3) fixed time interval (_fixed)
%                                AniposeData.allcolums, 
%                                EMG_biceps
%                                EMG_triceps
%                                EMG_ecu
%                                EMG_trap
%                                start_ts
%                                end_ts
%                                start_idx
%                                end_idx
% Inputs:
% 	aniposeData
% 	solenoid_on
% 	spoutContact_on
% 	videoFrames_timestamps
% 	laserTrig
% 	EMG_biceps
% 	EMG_triceps
% 	EMG_ecu
% 	EMG_trap
%   aniposeNumTS & ephysNumTS: time samples from start of reach for fixed interval extraction

%trial segementation, segments trials from anipose data based on solenoid and spout contact, sorts trials into %lightON and lightOFF
%Anipose data segmented is a matrix,  each trial is a matrix  of openEphys index number X marker/error/EMG data
%each trial is the data(open Ephys and Anipose) between, Openephys index solenoidON and SpoutcontactON,
%if laser trigger within each trial is not equal to 0, sort into laserON,
%	condition: LightOFF/LightON, LightON and LightOFF trials (HEADER), each  N x 2  where N is the number %of trials,
%1> determine real trials, all values between solenoid ON indx and first spout contactON idx % mice make multiple %contacts in one trial we want to ignore those or use them later?
%2> eliminate trials before first video frame index % no video is recorded at this time
%concatenate videoFrames_timestamps vercat to Aniposedata 
%This code identifies the index positions corresponding to the the start and end of each, a trial starts with a solenoid_on and ends with the first spout contact,  it runs several checks to avoid multiple spout contacts and to account for trials where reward is presented but a reach does not happen, if this occurs within the recording or on the last trial

% Get First and all spout contact immediately after each start event (solenoid_on) and before next start event
[spoutContact_first, spoutContact_multi, hitormiss] = getSpoutContact(solenoid_on, spoutContact_on);

% Get contData.Timestamp reference for start and end of trial; As well as index into contData.Timestamp and anipose
%	- start_ts: contData.Timestamp value of start of trial
%	- start_idx: Index into contData.Timestamp; Also, index into aniposeData (row number)
%	- end_ts_first/ end_ts_last: contData.Timestamp value of first and last spout contact of trial (end of trial)
%	- end_ts_idx/ end_ts_idx: Index into contData.Timestamp and aniposeData for first and last spout contact of trial
[start_ts, start_idx,...
 end_ts_first, end_idx_first,...
 end_ts_last, end_idx_last] = getTrialEventInfo(solenoid_on, videoFrames_timestamps, hitormiss,...
  												spoutContact_first, spoutContact_multi);

% laserTrig is wrt contData.Timestamps
lightOnTrig_ts=contDataTimestamps(find(laserTrig>3.3));

trial_list = [];

for i = 1:min(length(start_ts), length(end_ts_first))
	trial_list(i).hitormiss = hitormiss(i);
	if ~isnan(start_ts(i))
		trial_list(i).start_ts = start_ts(i);
		trial_list(i).start_idx = start_idx(i);
		trial_list(i).spoutContact_idx = sc_indx(i);
		% aniposeData and videoFrames_timestamps have the same # of total samples and are aligned with each other
		% start_idx is the index into videoFrames_timestamps and hence that can be used directly for aniposeData
		% i.e. index into videoFrames_timestamps is same as index into aniposedata
		trial_list(i).aniposeData_fixed = aniposeData(start_idx(i):min(size(aniposeData, 1), start_idx(i)+aniposeNumTS-1), :);
		% ephys data and contData timestamps have the same # of samples and are aligned with each other
		% Find index into contDataTimestamps using videoFrames_timestamps value, i.e. start_ts
		ephys_start_idx = find(contDataTimestamps == start_ts(i));
		ephys_end_idx_fixed = ephys_start_idx+ephysNumTS-1;
		% Use this index into contDataTimestamps to reference data from EMG channels
		trial_list(i).EMG_biceps_fixed = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_fixed))';
		trial_list(i).EMG_triceps_fixed = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_fixed))';
		trial_list(i).EMG_ecu_fixed = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_fixed))';
		trial_list(i).EMG_trap_fixed = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_fixed))';
		% lightOnTrig_ts is a subset of contDataTimestamps
		% and start_ts is from videoFrames_timestamps, which is a subset of contDataTimestamps
		% Hence lightOnTrig_ts value is comparable to start_ts (do not use index)
		trial_list(i).lightOnTrig_ts_fixed = intersect(start_ts(i):start_ts(i)+ephysNumTS-1, lightOnTrig_ts);
		if isempty(trial_list(i).lightOnTrig_ts_fixed)
			trial_list(i).lightTrig_fixed = 'OFF';
		else
			trial_list(i).lightTrig_fixed = 'ON';
		end
		if ~isnan(end_ts_first(i)) & (trial_list(i).hitormiss==1)
			% comment
			trial_list(i).lightOnTrig_ts = intersect(start_ts(i):end_ts_first(i), lightOnTrig_ts);
			if isempty(trial_list(i).lightOnTrig_ts)
				trial_list(i).lightTrig = 'OFF';
			else
				trial_list(i).lightTrig = 'ON';
			end
			trial_list(i).end_ts_first = end_ts_first(i);
			trial_list(i).end_ts_last = end_ts_first(i);
			trial_list(i).end_idx_first = end_idx_first(i);
			trial_list(i).end_idx_last = end_idx_last(i);
			% takes all the anipose data between each start and end index
			% Assumption: ephysNumTS is the same for index as well as time samples for fixed interval
			if end_idx_first(i)<size(aniposeData, 1)
				trial_list(i).aniposeData_first_sc = aniposeData(start_idx(i):end_idx_first(i), :);
				trial_list(i).aniposeData_last_sc = aniposeData(start_idx(i):end_idx_last(i), :);
				
			else
				trial_list(i).aniposeData_first_sc = [];
				trial_list(i).aniposeData_last_sc = [];
			end
			% takes all the EMG data between each start and end index
			ephys_end_idx_first_sc = find(contDataTimestamps == end_ts_first(i));
			ephys_end_idx_last_sc = find(contDataTimestamps == end_ts_last(i));
			trial_list(i).EMG_biceps_first_sc = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_first_sc))';
			trial_list(i).EMG_triceps_first_sc = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_first_sc))';
			trial_list(i).EMG_ecu_first_sc = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_first_sc))';
			trial_list(i).EMG_trap_first_sc = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_first_sc))';
			trial_list(i).EMG_biceps_last_sc = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_last_sc))';
			trial_list(i).EMG_triceps_last_sc = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_last_sc))';
			trial_list(i).EMG_ecu_last_sc = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_last_sc))';
			trial_list(i).EMG_trap_last_sc = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_last_sc))';
		else
			trial_list(i).lightOnTrig_ts = trial_list(i).lightOnTrig_ts_fixed;
			trial_list(i).lightTrig = trial_list(i).lightTrig_fixed;
			trial_list(i).aniposeData_first_sc = [];
			trial_list(i).aniposeData_last_sc = [];
			trial_list(i).EMG_biceps_first_sc = [];
			trial_list(i).EMG_triceps_first_sc = [];
			trial_list(i).EMG_ecu_first_sc = [];
			trial_list(i).EMG_trap_first_sc = [];
			trial_list(i).EMG_biceps_last_sc = [];
			trial_list(i).EMG_triceps_last_sc = [];
			trial_list(i).EMG_ecu_last_sc = [];
			trial_list(i).EMG_trap_last_sc = [];
		end
	end
end




