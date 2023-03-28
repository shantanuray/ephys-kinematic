function [endpoint]= getEndpoint(trial, prcocesslabel,poseID)
% uses calculated endpoint idx to find the corresponding value in relative data 
if nargin<3
   poseID='right_wrist_r';
end

if nargin<2
   processlabel='aniposeData_reach_relative';
end 
[VelocityMinimafirst_sc_endpoint_idx,VelocityMinimagripAperture_endpoint_idx]=getReachEnd(trial);

trial_pose=[trial.process.([poseID])];
endpoint=trial_pose(VelocityMinimagripAperture_endpoint_idx);
