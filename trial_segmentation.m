
function trial_list = trial_segmentation(aniposeData,...
										   solenoid_on,...
										   spoutContact_on,...
										   videoFrames_timestamps,...
										   laserTrig,...
										   EMG_biceps,...
										   EMG_triceps,...
										   EMG_ecu,...
										   EMG_trap)
% trial_list = trial_segmentation(aniposeData,...
		% 						   solenoid_on,...
		% 						   spoutContact_on,...
		% 						   videoFrames_timestamps,...
		% 						   laserTrig,...
		% 						   EMG_biceps,...
		% 						   EMG_triceps,...
		% 						   EMG_ecu,...
		% 						   EMG_trap);
%Output:
% ----------------
% 	trial_list: struct array with fields:
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
for i = 1:length(solenoid_on) % starts a for loop which will cycle through all the values in solenoid_on
	tmp_index = find(spoutContact_on > solenoid_on(i)); %defines a variable tmp_index that for all values of solenoid on finds the value in spoutContact_on that is higher
	if isempty(tmp_index)
		%  starts an if statement that writes an NaN in case the last value of solenoid on does not have a spoutconact after i.e mouse did not reach
		curr_spoutContact_on = nan;
	else
		curr_spoutContact_on = spoutContact_on(tmp_index(1));
	end
	if i < length(solenoid_on) %starts an if statement, where for all values except the last index value, the code checks that the spoutContact value corresponds to the current solenoid_on value and not the next 
		if ~isempty(tmp_index)
			if (spoutContact_on(tmp_index(1)) > solenoid_on(i+1))
	   			spoutContact_on_first = [spoutContact_on_first; nan];
			else
		 		spoutContact_on_first = [spoutContact_on_first; curr_spoutContact_on]; 
		 	end
		 end
	else
		spoutContact_on_first = [spoutContact_on_first; curr_spoutContact_on]; % for the last value, do not check the next value because it will be empty 
	end
end

%This code identifies the frame timestamps that correspond to the start and end of each trial, note video frame timestamps do not exactly correspond to openEphys timestamps because of videos are sampled at 200fps every 50ms of openEphys data
start_ts = [];
start_idx = [];
for i = 1:length(solenoid_on) % starts a for loop which will cycle through all the values in solenoid_on
	tmp_indx1 = find(videoFrames_timestamps<=solenoid_on(i));%looks for all the frame timestamps that happen before the solenoid on value
	if isempty(tmp_indx1)
		tmp_indx1 = nan;
	end
	start_ts = [start_ts; videoFrames_timestamps(tmp_indx1(end))];%selects the last one, this is the closest frame timestamp value to the solenoid on value
	start_idx = [start_idx; tmp_indx1(end)];
end
end_ts=[];
end_idx=[];
for j=1:length(spoutContact_on_first)
	if isnan(spoutContact_on_first(j))
		tmp_indx2 = nan;
	else
		tmp_indx2 = find(videoFrames_timestamps>=spoutContact_on_first(j));%looks for all the frame timestamps that happen after the first spout contact on value
	end
	if isempty(tmp_indx2)
		tmp_indx2 = nan;
	end
	end_ts = [end_ts; videoFrames_timestamps(tmp_indx2(1))]; %selects the first value, this is the closest frame timestamp to the first spout contact on value 
end_idx = [end_idx; tmp_indx2(1)]; 
end

% comment
lightOnTrig=find(laserTrig>3.3);

trial_list = [];

for i = 1:min(length(start_ts), length(end_ts))
	trial = struct();
	if ~(isnan(start_ts(i)) | isnan(end_ts(i)))
		trial.start_ts = start_ts;
		trial.end_ts = end_ts;
		trial.start_idx = start_idx;
		trial.end_idx = end_idx;
		% comment
		if isempty(intersect(start_ts(i):end_ts(i), lightOnTrig))
			trial.lightTrig = 'OFF';
		else
			trial.lightTrig = 'ON';
		end
		if round(end_idx(i)<size(aniposeData, 1)
			trial.aniposeData = aniposeData(start_idx(i):end_idx(i), :); % takes all the anipose data between each start and end index; converts time stamps in ephys data (30khz) to anipseData (200hz)
		else
			trial.aniposeData = [];
		end
		% takes all the EMG data between each start and end index ;
		trial.EMG_biceps=EMG_biceps(:, start_ts(i):end_ts(i))';
		trial.EMG_triceps=EMG_triceps(:, start_ts(i):end_ts(i))';
		trial.EMG_ecu=EMG_ecu(:, start_ts(i):end_ts(i))';
		trial.EMG_trap=EMG_trap(:, start_ts(i):end_ts(i))';
		trial_list = [trial_list; trial];
	end
end




