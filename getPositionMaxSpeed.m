function [speedMax_idx]=getPositionMaxSpeed(trial)

    %defining reference points 
    %% calculate the azimuth angle between initial position  at start of segment and postion at max velocity of the pull lift segment 
    pose_ID='right_wrist_r';
    % get trial relative speed
    trial_velocity=-[trial.aniposeData_fixed_relative_velocity.([pose_ID])];
    trial_speedMax=max(trial_velocity);
    speedMax_idx=find(trial_velocity==trial_speedMax);

    