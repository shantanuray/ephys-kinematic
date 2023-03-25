function endpoint = getEndpoint_v2(trial, reachPhase, bodyPart, relativeLabelFlag)
    % Get end point coordinates of a particular phase of the reach (reach, grasp) for given body part
    % endpoint = getEndpoint(trial, reachPhase)
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
    %   endpoint coordinates
 
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
    dataLabel = strcat('aniposeData_', reachPhase, relativeLabel);
    % Init endpoint index
    endpointIdx = Inf;
    if ~isfield(trial, dataLabel)
        disp('getEndpoint: Unable to find specified data label - %s', dataLabel);
        disp('Returning reach endpoint instead')
        [VelocityMinimafirst_sc_endpoint_idx, endpointIdx] = getReachEnd(trial);
    end
    % Find all possible measurements (_x, _y, _z, _r, ...) for body part
    bodyPartColPos = findColPos(trial.(dataLabel), bodyPart);
    dataLengthMax = height(trial.(dataLabel)(:,1)); % Use first col to find length
    endpoint = trial.(dataLabel)(min(endpointIdx, dataLengthMax), bodyPartColPos);
