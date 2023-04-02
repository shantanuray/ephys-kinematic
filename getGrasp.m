function [grasp_start_idx,grasp_end_idx]=getGrasp(trial, VelocityMinimagripAperture_endpoint_idx,processlabel,poseID)
%get grasp 
%must be run after getReachEnd
%grasp is defined as reach end plus 500 ms 
% set reach end as the start of the grasp, idx wrt to trial start
if nargin<4
   poseID='right_wrist_r';
end

if nargin<3
   processlabel='aniposeData_fixed_relative';
end 

trial_pose=trial.(processlabel).(poseID);
if ~isnan (VelocityMinimagripAperture_endpoint_idx)
   grasp_start_idx=VelocityMinimagripAperture_endpoint_idx;
   % set grasp end to grasp start plus 100 samples (i.e 0.5seconds)
   grasp_end_idx=grasp_start_idx+100;
   grasp_end_idx = min(grasp_end_idx, size(trial_pose, 1));
else 
grasp_start_idx =nan;
grasp_end_idx =nan;
end

	