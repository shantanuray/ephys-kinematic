
function trialList=cleanTriallist(trialList,displacementRef, processlabel,poseID);
%Trial cleanup 
%remove any trials whose displacement from reach start to end (wrist) is less than 17mm 
%something not working here 
%rewrite
if nargin<4
   poseID='right_wrist_r';
end

if nargin<3
   processlabel='aniposeData_reach_relative';
end 

if nargin<2
   displacementRef=12;
end 

for i=1:length(trialList)
    trial_pose=trialList(i).(processlabel).(poseID);
    displacement=abs(trial_pose(1)-trial_pose(end));
    if displacement>=displacementRef
        trialList(i).displacementThreshold = true;
    else
        trialList(i).displacementThreshold = false;
    end
end

