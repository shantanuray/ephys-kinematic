function endpointRelativeDistance = getReachEndpoint(trial, bodyPart)
    % Get end point distance (_r) from reference (eg. spout) of the reach phase for given body part
    % endpoint = getEndpoint(trial, bodyPart)
    %
    % Inputs:
    %   - trial: struct() with kinematic data stored as
    %   - bodyPart: 'right_wrist', 'right_knuckle_d', which contains measurement _r
    %                   Default = 'right_wrist'
    %  Output:
    %   - endpointRelativeDistance
 
    if nargin < 2
        bodyPart ='right_wrist';
    end
    % By default, return reach
    reachPhase = 'reach';
    % By default, return relative 
    relativeLabel = '_relative';

    dataLabel = strcat('aniposeData_', reachPhase, relativeLabel);
    % Init endpoint index
    endpointIdx = Inf;
    if ~isfield(trial, dataLabel)
        disp('getEndpoint: Unable to find specified data label - %s', dataLabel);
        disp('Returning reach endpoint instead')
        [VelocityMinimafirst_sc_endpoint_idx, endpointIdx] = getReachEnd(trial);
    end
    % Find all possible measurements (_x, _y, _z, _r, ...) for body part
    bodyPartColPos = findColPos(trial.(dataLabel), strcat(bodyPart, '_r'));
    dataLengthMax = height(trial.(dataLabel)(:,1)); % Use first col to find length
    endpointRelativeDistance = trial.(dataLabel)(min(endpointIdx, dataLengthMax), bodyPartColPos);
