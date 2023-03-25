function speedMax_idx = getPositionMaxSpeed_v2(trial, reachPhase, bodyPart, relativeLabelFlag)
    % Get index of kinematic data max speed in the specified phase of the reach (reach, grasp) for given body part
    % speedMax_idx = getPositionMaxSpeed_v2(trial, reachPhase, bodyPart, relativeLabelFlag)
    %
    % Inputs:
    %   - trial: struct() with kinematic data stored as
    %       # relativeLabelFlag: Boolean, Whether to use  or absolute coordinates
    %                   If true -> aniposeData_<reachPhase>_relative (Default)
    %                   If false -> aniposeData_<reachPhase>
    %       # bodyPart: 'right_wrist', 'right_knuckle_d', which contains measurement: _x, _y, _z
    %                   Default = 'right_wrist'
    %   - reachPhase is the phase of the reach from {'reach', 'grasp', 'first_sc', 'last_sc'}
    %       Default = 'reach'
    %  Output:
    %   Index at max speed
 
    reachPhaseOptions = {'fixed', 'reach', 'grasp', 'first_sc', 'last_sc'};
    if nargin < 2
        reachPhase = 'reach';
    end
    if nargin < 3
        bodyPart ='right_wrist';
    end
    % By default, return relative 
    relativeLabel = '_relative';
    % Else check for flag
    if nargin >= 4
        if ~relativeLabelFlag
            % Use absolute
            relativeLabel = '';
        end
    end

    if isempty(find(strcmpi(reachPhaseOptions, reachPhase)))
        error('getEndpoint: Incorrect reach phase specified - %s', reachPhase)
    end
    dataLabel = strcat('aniposeData_', reachPhase, relativeLabel, '_velocity');
    bodyPartLabel = strcat(bodyPart, '_r');
    trial_velocity = trial.(dataLabel).(bodyPartLabel);
    trial_speedMax = max(abs(trial_velocity));
    speedMax_idx = find(abs(trial_velocity)==trial_speedMax); % Note: May have multiple peaks