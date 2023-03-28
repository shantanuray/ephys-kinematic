function tortuosity=getTortuosity(trial,processlabel,poseID);
% Get Tortuosity
if nargin<3
   poseID='right_wrist_r';
end

if nargin<3
   processlabel='aniposeData_fixed_relative';
end 

trial_pose=[trial.(processlabel).([poseID])];
displacement=abs(trial_pose(1)-trial_pose(end));
pathlength= sum(abs(diff(trial_pose)));
tortuosity=pathlength/displacement;

