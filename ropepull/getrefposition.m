function [loc_data_start,loc_data_speed_max]=getrefposition(trial)

    %defining reference points 
    %% calculate the azimuth angle between initial position  at start of segment and postion at max velocity of the pull lift segment 
    colNameXYZ='trialXYZRhythymicPeakPreVhand_right';
    data_dv=trial.(colNameXYZ).data(:,1);
    data_dv=-data_dv;
    data_dv_max=max(data_dv);
    loc_data_dv_max=find(data_dv==data_dv_max);
    colNameref='speedRhythymicPeakPreVhand_right';
    data_speed=trial.(colNameref).data;
    loc_data_start=1;
    data_speed=data_speed(loc_data_start:loc_data_dv_max);
    data_speed_max=max(data_speed);
    loc_data_speed_max=find(data_speed==data_speed_max);
    if isempty(loc_data_speed_max)
        loc_data_start = [];
    end