function [wrist_endpoint, d3_knuckle_endpoint]= getEndpoint(trial)
% uses calculated endpoint idx to find the corresponding value in relative data 
[VelocityMinimagripAperture_endpoint_idx]=getReachEnd(trial);
pose_ID_wrist='right_wrist_r';
pose_ID_d3_knuckle='right_d3_knuckle_r';
trial_pose_ID_wrist=[trial.aniposeData_fixed_relative.([pose_ID_wrist])];
trial_pose_ID_d3_knuckle=[trial.aniposeData_fixed_relative.([pose_ID_d3_knuckle])];
wrist_endpoint=trial_pose_ID_wrist(VelocityMinimagripAperture_endpoint_idx);
d3_knuckle_endpoint=trial_pose_ID_d3_knuckle(VelocityMinimagripAperture_endpoint_idx);