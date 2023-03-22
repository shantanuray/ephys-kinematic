function [VelocityMinimafirst_sc_endpoint_idx,VelocityMinimagripAperture_endpoint_idx,first_sc_idx,gripAperture_max_idx]=getReachEnd(trial)
% gets the reach endpoint 
% two options are calculated 
% 1> velocity mina closest to spout contact
% 2> velocity minima closest to max grip aperture in a window around spout contact 
% to call it:
%idx is in reference to the current trial 
%[VelocityMinimafirst_sc_endpoint_idx,VelocityMinimagripAperture_endpoint_idx,first_sc_idx,gripAperture_max_idx]=getReachEnd(trial) 

pose_ID='right_wrist_r';
gripAperture= getGripAperture(trial);
%calculates the first cpout contact index
first_sc_idx=trial.end_idx_first-trial.start_idx;
%identifies the max grip aperture within a 50ms window around the spout contact;
first_sc_window=((trial.end_idx_first-200*100/1000)-trial.start_idx:(trial.end_idx_first+200*100/1000)-trial.start_idx);
%identifies max GA within the spout contact window
gripAperture_max=max(gripAperture(first_sc_window));
%GA idx
gripAperture_max_idx=find(gripAperture==gripAperture_max);

% get trial relative speed
trial_velocity=-[trial.aniposeData_fixed_relative_velocity.([pose_ID])];
%identifies local speed minima
velocityMinima= islocalmin(trial_velocity,'MinProminence',5);
% index on velocity minima, is local minima is true =1
velocityMinima_idx=find(velocityMinima==1);
% identifies velocity minima within the first sc window
velocityMinima_idx_first_sc_window= find(velocityMinima_idx>first_sc_window(1) & velocityMinima_idx<first_sc_window(end));
% gets the value for the index identified above
velocityMinima_idx_sc=velocityMinima_idx(velocityMinima_idx_first_sc_window);

%to identify the closest velocity minima to the GA subtract the indices
relativeVelocityMinimatogripAperture_idx=velocityMinima_idx_sc-gripAperture_max_idx;
%find the least distance away from GA
VelocityMinimagripAperture_endpoint=min(abs(relativeVelocityMinimatogripAperture_idx));
%finds the indx of the least distance away
VelocityMinimagripAperture_endpoint_idx=find(abs(relativeVelocityMinimatogripAperture_idx)==VelocityMinimagripAperture_endpoint);
%finds the indx of the velocity minima that is least distance away from GA and is wiithin the first sc window
VelocityMinimagripAperture_endpoint_idx=velocityMinima_idx_sc(VelocityMinimagripAperture_endpoint_idx);	

% calculates the distance (samples)between first sc and each velocity minima
relativeVelocityMinimatofirst_sc_idx=velocityMinima_idx-first_sc_idx;
% finds the one at least distance away 
VelocityMinimafirst_sc_endpoint=min(abs(relativeVelocityMinimatofirst_sc_idx));
%gets the index of the least distance away
VelocityMinimafirst_sc_endpoint_idx=find(abs(relativeVelocityMinimatofirst_sc_idx)==VelocityMinimafirst_sc_endpoint);
%finds the indx of the velocity minima that is closest to the spout contact 
VelocityMinimafirst_sc_endpoint_idx=velocityMinima_idx(VelocityMinimafirst_sc_endpoint_idx);
