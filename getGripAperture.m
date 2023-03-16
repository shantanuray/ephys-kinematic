function trial_list = getGripAperture(trial, processLabel, digit1label, digit2label)
    % Usage: getGripAperture(trial_list, dataLabels, digit1label,digit2label);
    % calculates the distance between digits specified, for classical grip aperture  calculations the tip of d2 and d5 would be used , but other markers such as the knuckle or other digits coulber be considered 
    % Input:
    %   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
    %   - dataLabels: cell array with data label names
    %                 eg. {'anipose_fixed'} or
    %                     {'anipose_fixed', 'anipose_first_sc'}
    %                 (default: {'aniposeData_fixed',...
    %                           'aniposeData_first_sc',...
    %                           'aniposeData_last_sc'})
    %   - digit1label:   string indicating digit1label (default: 'right_d5_tip')
    %   - digit2label:   string indicating digit2label (default:  'right_d2_tip')
    % Examples
    % trial_list = getRelativeDistance(trial_list, {'aniposeData_fixed'});
    % trial_list = getRelativeDistance(trial_list, {'aniposeData_fixed'}, 'right_d5_tip','right_d2_tip');

    % Assumption: Data is stored in a table in the following structure for each body part/ reference
    %   left_wrist_x,left_wrist_y,left_wrist_z,left_wrist_error,left_wrist_ncams,left_wrist_score,left_d1_knuckle_x,...
    %   Calculate and save relative distance for x,y,z only


    if nargin<4
            digit2label= 'right_d2_tip_r';
    end
    if nargin<3
        digit1label = 'right_d5_tip_r';
    end
    if nargin<2
            processLabel = 'aniposeData_fixed_relative';
    end
    digit1Value = trial.(processLabel).(digit1label);
    digit2Value = trial.(processLabel).(digit2label);
    gripAperture = digit2Value - digit1Value;
end