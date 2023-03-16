function [loc_data_absvelocity_max]=getVelocityMaxposition(trial)

    %defining reference points 
    %% calculate the azimuth angle between initial position  at start of segment and postion at max velocity of the pull lift segment
    % right_d3_knuckle , all process labels , velocity_relative
    colName=''; %velocity
    data_absvelocity=trial.(colNameXYZ).data(:,1);% data referencing
    data_absvelocity=-data_absvelocity;
    data_absvelocity_max=max(data_absvelocity);
    loc_data_absvelocity_max=find(data_absvelocity==data_absvelocity_max);
    
    