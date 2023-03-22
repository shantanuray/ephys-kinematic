function[azi,elev]=getAngleRefPosition(trial,startPos,endPos)
%get directional angle between two reference points 
%startPos is the sart position i.e windowCandidate.startPos
%endPos is either the endpoint (VelocityMinimagripAperture_endpoint_idx) or the position at max speed (speedMax_idx)
% angle is between x,y,z/r at start and x,y,z/r at end
pose_ID='right_wrist';
%use the x,y,z components of relative dist
trial_pose_xyz=[trial.aniposeData_fixed_relative.([pose_ID,'_x']), trial.aniposeData_fixed_relative.([pose_ID,'_y']),trial.aniposeData_fixed_relative.([pose_ID,'_z'])];
% calculates vector between the two positions
data_ref=trial_pose_xyz([startPos endPos],:);
data_ref=diff(data_ref);
% transforms data so the ML co-ordinate(z) is first, AP co-ordinate(x) is second, and DV co-ordinate(y) is third 
[azi,elev]=cart2sph(data_ref(:,3),data_ref(:,1),data_ref(:,2)); 
azi=rad2deg(azi);
elev=rad2deg(elev);