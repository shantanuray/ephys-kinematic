function [grasp_start_idx,grasp_end_idx]=getGrasp(trial, VelocityMinimagripAperture_endpoint_idx)
%get grasp 
%must be run after getReachEnd
%grasp is defined as reach end plus 500 ms 
% set reach end as the start of the grasp, idx wrt to trial start
grasp_start_idx=VelocityMinimagripAperture_endpoint_idx;
% set grasp end to grasp start plus 100 samples (i.e 0.5seconds)
grasp_end_idx=grasp_start_idx+100;

	