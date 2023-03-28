function speedMax_idx=getPositionMaxSpeed(trial,processlabel,poseID)

    %defining reference points 
    %% calculate the azimuth angle between initial position  at start of segment and postion at max velocity of the pull lift segment 
    if nargin < 3
        processlabel = 'aniposeData_reach_relative_velocity';
    end
    if nargin < 2
        pose_ID='right_wrist_r';
    end

    pose_ID='right_wrist_r';
    % get trial relative speed
    trial_velocity=-trial.(processlabel).(pose_ID);
    trial_speedMax=max(trial_velocity);
    speedMax_idx=find(trial_velocity==trial_speedMax);

    