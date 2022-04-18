
function trial_list = trialSegmentationMultiEvent(aniposeData,...
										   solenoid_on,...
										   tone_on,...
										   spoutContact_on,...
										   perchContact_on, perchContact_off,...
										   videoFrames_timestamps,...
										   laserTrig,...
										   EMG_biceps,...
										   EMG_triceps,...
										   EMG_ecu,...
										   EMG_trap,...
										   aniposeNumTS,...
										   ephysNumTS,...
										   contDataTimestamps)
	% trial_list = trialSegmentationMultiEvent(aniposeData,...
	% 										   solenoid_on,...
	% 										   tone_on,...
	% 										   spoutContact_on,...
	% 										   videoFrames_timestamps,...
	% 										   laserTrig,...
	% 										   EMG_biceps,...
	% 										   EMG_triceps,...
	% 										   EMG_ecu,...
	% 										   EMG_trap,...
	% 										   aniposeNumTS,...
	% 										   ephysNumTS,...
	% 										   contDataTimestamps);
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
	% aniposeData: 
	% solenoid_on: 
	% tone_on: 
	% spoutContact_on: 
	% videoFrames_timestamps: 
	% laserTrig: 
	% EMG_biceps: 
	% EMG_triceps: 
	% EMG_ecu: 
	% EMG_trap: 
	% aniposeNumTS: 
	% ephysNumTS: 
	% contDataTimestamps

	%trial segementation, segments trials from anipose data based on solenoid and spout contact, sorts trials into %lightON and lightOFF
	%Anipose data segmented is a matrix,  each trial is a matrix  of openEphys index number X marker/error/EMG data
	%each trial is the data(open Ephys and Anipose) between, Openephys index solenoidON and SpoutcontactON,
	%if laser trigger within each trial is not equal to 0, sort into laserON,
	%	condition: LightOFF/LightON, LightON and LightOFF trials (HEADER), each  N x 2  where N is the number %of trials,
	%1> determine real trials, all values between solenoid ON indx and first spout contactON idx % mice make multiple %contacts in one trial we want to ignore those or use them later?
	%2> eliminate trials before first video frame index % no video is recorded at this time
	%concatenate videoFrames_timestamps vercat to Aniposedata 
	%This code identifies the index positions corresponding to the the start and end of each, a trial starts with a solenoid_on and ends with the first spout contact,  it runs several checks to avoid multiple spout contacts and to account for trials where reward is presented but a reach does not happen, if this occurs within the recording or on the last trial

	% Get First and all spout contact immediately after each start event (solenoid_on/ tone_on) and before next start event
	perchContact_cont = convert_to_continuous(perchContact_on, perchContact_off, contDataTimestamps);
	[spoutContact_first_solenoid, spoutContact_multi_solenoid, hitormiss_solenoid, perchOnStart_solenoid] = getSpoutContact(solenoid_on, spoutContact_on, perchContact_cont);
	[spoutContact_first_tone, spoutContact_multi_tone, hitormiss_tone, perchOnStart_tone] = getSpoutContact(tone_on, spoutContact_on, perchContact_cont);

	% Get contData.Timestamp reference for start and end of trial; As well as index into contData.Timestamp and anipose
	%	- start_ts: contData.Timestamp value of start of trial
	%	- start_idx: Index into contData.Timestamp; Also, index into aniposeData (row number)
	%	- end_ts_first/ end_ts_last: contData.Timestamp value of first and last spout contact of trial (end of trial)
	%	- end_ts_idx/ end_ts_idx: Index into contData.Timestamp and aniposeData for first and last spout contact of trial
	[start_ts_solenoid, start_idx_solenoid,...
	 end_ts_first_solenoid, end_idx_first_solenoid,...
	 end_ts_last_solenoid, end_idx_last_solenoid] = getTrialEventInfo(solenoid_on, videoFrames_timestamps, hitormiss_solenoid,...
	  												 		 		  spoutContact_first_solenoid, spoutContact_multi_solenoid);
	[start_ts_tone, start_idx_tone,...
	 end_ts_first_tone, end_idx_first_tone,...
	 end_ts_last_tone, end_idx_last_tone] = getTrialEventInfo(tone_on, videoFrames_timestamps, hitormiss_tone,...
	  												 	 	  spoutContact_first_tone, spoutContact_multi_tone);
	

	% laserTrig is wrt contData.Timestamps
	lightOnTrig_ts=contDataTimestamps(find(laserTrig>3.3));

	trial_list = [];

	for i = 1:min(length(solenoid_on), length(tone_on))
		trial_solenoid = getTrialInfo(aniposeData,...
									  EMG_biceps,...
									  EMG_triceps,...
									  EMG_ecu,...
									  EMG_trap,...
									  'solenoid',...
		  							  aniposeNumTS, ephysNumTS,...
		  							  contDataTimestamps,...
									  lightOnTrig_ts,...
		  							  hitormiss_solenoid(i),...
		  							  perchOnStart_solenoid(i),...
									  start_ts_solenoid(i), start_idx_solenoid(i),...
									  end_ts_first_solenoid(i), end_idx_first_solenoid(i),...
									  end_ts_last_solenoid(i), end_idx_last_solenoid(i));

		trial_tone = getTrialInfo(aniposeData,...
								  EMG_biceps,...
								  EMG_triceps,...
								  EMG_ecu,...
								  EMG_trap,...
								  'tone',...
	  							  aniposeNumTS, ephysNumTS,...
	  							  contDataTimestamps,...
								  lightOnTrig_ts,...
	  							  hitormiss_tone(i),...
	  							  perchOnStart_tone(i),...
								  start_ts_tone(i), start_idx_tone(i),...
								  end_ts_first_tone(i), end_idx_first_tone(i),...
								  end_ts_last_tone(i), end_idx_last_tone(i));
		trial = trial_solenoid;
		f = fieldnames(trial_tone);
		for f_indx = 1:length(f)
		    trial.(f{f_indx}) = trial_tone.(f{f_indx});
		end
		trial_list = [trial_list, trial];
	end	
end