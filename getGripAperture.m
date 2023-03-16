function trial_list = getGripAperture(trial, processLabel, digit1label, digit2label)
    % Usage: getGripAperture(trial_list, processLabel, digit1label, digit2label);
    % calculates the distance between digits specified, for classical grip aperture  calculations the tip of d2 and d5 would be used , but other markers such as the knuckle or other digits coulber be considered 
    % Input:
    %   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
    %   - processLabel: str, Default = 'aniposeData_fixed_relative'
    %   - digit1label:   string indicating digit1label (default: 'right_d5_tip_r')
    %   - digit2label:   string indicating digit2label (default:  'right_d2_tip_r')
    % Examples
    % trial_list = getGripAperture(trial_list, 'aniposeData_fixed_relative'});
    % trial_list = getGripAperture(trial_list, 'aniposeData_fixed_relative', 'right_d5_tip_r','right_d2_tip_r');


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