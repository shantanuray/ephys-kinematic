%Trial cleanup 
%remove any trials whose displacement from reach start to end (wrist) is less than 17mm 
%something not working here 
trialList=trialList_tone_on;
poseID='right_wrist_r';
data='aniposeData_fixed_relative';
wrist_displacement_binary=[];
for i=1:length(trialList)
    trial=trialList(i);
    windowCandidate(i) = findReachStart(trial,'RefBodyPart', 'right_wrist_r','WindowStartKinematicVariable', 'aniposeData_fixed_relative','WindowStartLimitValue',3,'WindowSearchKinematicVariable','aniposeData_fixed_relative_jerk','WindowSelectorVariable','aniposeData_fixed_relative_velocity','WindowSelectorLimitValue', -10,'MinPeakDistance', 10,'MinPeakHeight', 3);
    startPos(i)=windowCandidate(i).startPos;
    trial_pose=[trial.(data).([poseID])];
    startPoseValue(i)=trial_pose(startPos(i));
    wrist_endpoint(i)= getEndpoint(trial);
    wrist_displacement(i)=abs(wrist_endpoint(i)-startPoseValue(i));
    if wrist_displacement(i)>=15
       wrist_displacement_binary(i)=1;
    else    
       wrist_displacement_binary(i)=0;
    end   
    wrist_displacement_binary=[wrist_displacement_binary,wrist_displacement(i)];
end