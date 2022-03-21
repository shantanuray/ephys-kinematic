
function trial_list = trial_segmentation(aniposeData,...
										   solenoid_on,...
										   spoutContact_on,...
										   videoFrames_timestamps,...
										   laserTrig,...
										   EMG_biceps,...
										   EMG_triceps,...
										   EMG_ecu,...
										   EMG_trap,...
										   numTS)
% trial_list = trial_segmentation(aniposeData,...
		% 						   solenoid_on,...
		% 						   spoutContact_on,...
		% 						   videoFrames_timestamps,...
		% 						   laserTrig,...
		% 						   EMG_biceps,...
		% 						   EMG_triceps,...
		% 						   EMG_ecu,...
		% 						   EMG_trap,...
		%						   numTS);
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
%   numTS  				  - Extract numTS time samples from start of reach for fixed interval extraction
%trial segementation, segments trials from anipose data based on solenoid and spout contact, sorts trials into %lightON and lightOFF
%Anipose data segmented is a matrix,  each trial is a matrix  of openEphys index number X marker/error/EMG data
%each trial is the data(open Ephys and Anipose) between, Openephys index solenoidON and SpoutcontactON,
%if laser trigger within each trial is not equal to 0, sort into laserON,
%	condition: LightOFF/LightON, LightON and LightOFF trials (HEADER), each  N x 2  where N is the number %of trials,
%1> determine real trials, all values between solenoid ON indx and first spout contactON idx % mice make multiple %contacts in one trial we want to ignore those or use them later?
%2> eliminate trials before first video frame index % no video is recorded at this time
%concatenate videoFrames_timestamps vercat to Aniposedata 
%This code identifies the index positions corresponding to the the start and end of each, a trial starts with a solenoid_on and ends with the first spout contact,  it runs several checks to avoid multiple spout contacts and to account for trials where reward is presented but a reach does not happen, if this occurs within the recording or on the last trial

spoutContact_on_first = [];% creates an empty array for the first spout contact after each reward presentation (solenoid_on) which can be filled with values generated below
spoutContact_on_multi = cell(length(solenoid_on), 1);% creates an empty array for the all spout contacts after each reward presentation (solenoid_on) and before next reward presentation
hitormiss = zeros(length(solenoid_on), 1);
for i = 1:length(solenoid_on) % starts a for loop which will cycle through all the values in solenoid_on
	first_sc_index = find(spoutContact_on > solenoid_on(i)); %defines a variable tmp_index that for all values of solenoid on finds the value in spoutContact_on that is higher
	if isempty(first_sc_index)
		%  starts an if statement that writes an NaN in case the last value of solenoid on does not have a spoutconact after i.e mouse did not reach
		curr_spoutContact_on = nan;
	else
		curr_spoutContact_on = spoutContact_on(first_sc_index(1));
	end
	if i < length(solenoid_on) %starts an if statement, where for all values except the last index value, the code checks that the spoutContact value corresponds to the current solenoid_on value and not the next 
		if ~isempty(first_sc_index)
			if (spoutContact_on(first_sc_index(1)) > solenoid_on(i+1))
	   			spoutContact_on_first = [spoutContact_on_first; nan];
			else
				hitormiss(i) = 1;
				% Find all spout contacts after each reward presentation (solenoid_on) and before next reward presentation
				all_sc_index = find(spoutContact_on(first_sc_index) < solenoid_on(i+1));
				spoutContact_on_multi{i} = spoutContact_on(all_sc_index + first_sc_index(1) - 1);
				% Note first spout contact
		 		spoutContact_on_first = [spoutContact_on_first; curr_spoutContact_on]; 
		 	end
		 end
	else
		if ~isempty(first_sc_index)
			hitormiss(i) = 1;
		end
		spoutContact_on_first = [spoutContact_on_first; curr_spoutContact_on]; % for the last value, do not check the next value because it will be empty 
		spoutContact_on_multi{i} = [curr_spoutContact_on];
	end
end

%This code identifies the frame timestamps that correspond to the start and end of each trial, note video frame timestamps do not exactly correspond to openEphys timestamps because of videos are sampled at 200fps every 50ms of openEphys data
start_ts = [];
start_idx = [];
for i = 1:length(solenoid_on) % starts a for loop which will cycle through all the values in solenoid_on
	tmp_indx1 = find(videoFrames_timestamps<=solenoid_on(i));%looks for all the frame timestamps that happen before the solenoid on value
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
	sc_indx = nan;
	if ~isnan(spoutContact_on_first(j))
		%looks for all the frame timestamps that happen after the first spout contact on value
		sc_indx = find(videoFrames_timestamps>=spoutContact_on_first(j));
	end
	if ~(isnan(sc_indx) & isempty(sc_indx)) & hitormiss(j)==1
		% Get time stamp value and index of end of first spout contact
		%selects the first value of the time stamp, this is the closest frame timestamp to the first spout contact on value 
		end_ts_first = [end_ts_first; videoFrames_timestamps(sc_indx(1))]; 
		end_idx_first = [end_idx_first; sc_indx(1)];

		%looks for all the frame timestamps that happen after the first spout contact uptil the last spout contact before next solenoid on
		last_sc_indx = find(videoFrames_timestamps(sc_indx)<=spoutContact_on_multi{j}(end));
		% In case there is only one spout contact, use the first sc
		if isempty(last_sc_indx)
			last_sc_indx = 1;
		end
		%selects the first value of the time stamp, this is the closest frame timestamp to the resp. spout contact
		end_ts_last = [end_ts_last; videoFrames_timestamps(sc_indx(1)+last_sc_indx(end)-1)]; 
		end_idx_last = [end_idx_last; sc_indx(1)+last_sc_indx(end)-1];
	else
		% For no spout contact, init to nan
		end_ts_first = [end_ts_first; nan];
		end_idx_first = [end_idx_first; nan];
		end_ts_last = [end_ts_last; nan];
		end_idx_last = [end_idx_last; nan];
	end
end

% comment
lightOnTrig=find(laserTrig>3.3);

trial_list = [];

for i = 1:min(length(start_ts), length(end_ts_first))
	trial_list(i).hitormiss = hitormiss(i);
	if ~isnan(start_ts(i))
		trial_list(i).start_ts = start_ts(i);
		trial_list(i).start_idx = start_idx(i);
		trial_list(i).aniposeData_fixed = aniposeData(start_idx(i):min(size(aniposeData, 1), end_idx_first(i)+numTS-1), :);
		trial_list(i).EMG_biceps_fixed = EMG_biceps(:, start_ts(i):min(size(EMG_biceps, 2), start_ts(i)+numTS-1))';
		trial_list(i).EMG_triceps_fixed = EMG_triceps(:, start_ts(i):min(size(EMG_triceps, 2), start_ts(i)+numTS-1))';
		trial_list(i).EMG_ecu_fixed = EMG_ecu(:, start_ts(i):min(size(EMG_ecu, 2), start_ts(i)+numTS-1))';
		trial_list(i).EMG_trap_fixed = EMG_trap(:, start_ts(i):min(size(EMG_trap, 2), start_ts(i)+numTS-1))';
		if ~isnan(end_ts_first(i)) & (trial_list(i).hitormiss==1)
			% comment
			trial_list(i).lightOnTrig_ts = intersect(start_ts(i):end_ts_first(i), lightOnTrig);
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
			% Assumption: numTS is the same for index as well as time samples for fixed interval
			if end_idx_first(i)<size(aniposeData, 1)
				trial_list(i).aniposeData_first_sc = aniposeData(start_idx(i):end_idx_first(i), :);
				trial_list(i).aniposeData_last_sc = aniposeData(start_idx(i):end_idx_last(i), :);
				
			else
				trial_list(i).aniposeData_first_sc = [];
				trial_list(i).aniposeData_last_sc = [];
			end
			% takes all the EMG data between each start and end index
			trial_list(i).EMG_biceps_first_sc = EMG_biceps(:, start_ts(i):min(size(EMG_biceps, 2), end_ts_first(i)))';
			trial_list(i).EMG_triceps_first_sc = EMG_triceps(:, start_ts(i):min(size(EMG_triceps, 2), end_ts_first(i)))';
			trial_list(i).EMG_ecu_first_sc = EMG_ecu(:, start_ts(i):min(size(EMG_ecu, 2), end_ts_first(i)))';
			trial_list(i).EMG_trap_first_sc = EMG_trap(:, start_ts(i):min(size(EMG_trap, 2), end_ts_first(i)))';
			trial_list(i).EMG_biceps_last_sc = EMG_biceps(:, start_ts(i):min(size(EMG_biceps, 2), end_ts_last(i)))';
			trial_list(i).EMG_triceps_last_sc = EMG_triceps(:, start_ts(i):min(size(EMG_triceps, 2), end_ts_last(i)))';
			trial_list(i).EMG_ecu_last_sc = EMG_ecu(:, start_ts(i):min(size(EMG_ecu, 2), end_ts_last(i)))';
			trial_list(i).EMG_trap_last_sc = EMG_trap(:, start_ts(i):min(size(EMG_trap, 2), end_ts_last(i)))';
		else
			trial_list(i).lightOnTrig_ts = intersect(start_ts(i):start_ts(i)+numTS-1, lightOnTrig);
			if isempty(trial_list(i).lightOnTrig_ts)
				trial_list(i).lightTrig = 'OFF';
			else
				trial_list(i).lightTrig = 'ON';
			end
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




