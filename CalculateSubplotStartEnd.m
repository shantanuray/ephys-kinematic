%CalculateSubplotStartEnd
%calling function that gets trial start and end, plots and saves  the data 

trialList=trialList_tone_on;
trialNum=23;
trial=trialList(trialNum);
pose_ID='right_wrist_r';

%gets the endpoint
[VelocityMinimafirst_sc_endpoint_idx,VelocityMinimagripAperture_endpoint_idx,first_sc_idx,gripAperture_max_idx]=getReachEnd(trial);

%gets GA
gripAperture= getGripAperture(trial); 

trial_velocity=-[trial.aniposeData_fixed_relative_velocity.([pose_ID])];

%identifies local speed minima
velocityMinima= islocalmin(trial_velocity,'MinProminence',5);
% index on velocity minima, is local minima is true =1
velocityMinima_idx=find(velocityMinima==1);

trial_velocity=-[trial.aniposeData_fixed_relative_velocity.([pose_ID])];
%identifies local speed minima
velocityMinima= islocalmin(trial_velocity,'MinProminence',5);
% index on velocity minima, is local minima is true =1
velocityMinima_idx=find(velocityMinima==1);

trial_pose=[trial.aniposeData_fixed_relative.([pose_ID])];

trial_jerk=[trial.aniposeData_fixed_relative_jerk.([pose_ID])];
[jerkpks,jerkloc]=findpeaks(trial_jerk,'MinPeakDistance',5);
%'MinPeakHeight', 3

windowCandidate = findReachStart(trial,'RefBodyPart', 'right_d3_knuckle_r','WindowStartKinematicVariable', 'aniposeData_fixed_relative','WindowStartLimitValue',3,'WindowSearchKinematicVariable','aniposeData_fixed_relative_jerk','WindowSelectorVariable','aniposeData_fixed_relative_velocity','WindowSelectorLimitValue', -10,'MinPeakDistance', 10,'MinPeakHeight', 3);

startPos=windowCandidate.startPos;




