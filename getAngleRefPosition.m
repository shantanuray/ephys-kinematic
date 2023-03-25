function [azi,elev]=getAngleRefPosition(trial, endPos, startPos, dataLabel, bodyPart)
    % Get directional angle between two reference points 
    % [azi,elev] = getAngleRefPosition(trial, dataLabel, bodyPart, startPos,endPos)
    % Input:
    %   - trial: struct() with kinematic data stored as
    %       # dataLabel: aniposeData_fixed_relative, aniposeData_reach, aniposeData_grasp
    %                   Default = 'aniposeData_reach'
    %       # bodyPart: 'right_wrist', 'right_knuckle_d', which contains measurement: _x, _y, _z
    %                   Default = 'right_wrist'
    %   - startPos is the start position i.e windowCandidate.startPos
    %   - endPos is either the endpoint (VelocityMinimagripAperture_endpoint_idx) or the position at max speed (speedMax_idx)
    %  Output:
    %   [azi,elev] of angle in degrees between x,y,z/r at start and x,y,z/r at end
    if nargin < 5
        bodyPart ='right_wrist';
    end
    if nargin < 4
        dataLabel = 'aniposeData_reach';
    end
    if nargin < 3
        startPos = 1;
    end
    if nargin < 2
        endPos = Inf;
    end
    %use the x,y,z components of relative dist
    trialXYZ = [trial.(dataLabel).([bodyPart,'_x']), trial.(dataLabel).([bodyPart,'_y']),trial.(dataLabel).([bodyPart,'_z'])];
    % calculates vector between the two positions
    relXYZ = trialXYZ([startPos, min(endPos, length(trialXYZ))], :);
    relXYZ = diff(relXYZ);
    % transforms data so the ML co-ordinate(z) is first, AP co-ordinate(x) is second, and DV co-ordinate(y) is third 
    [azi, elev] = cart2sph(relXYZ(:,3),relXYZ(:,1),relXYZ(:,2)); 
    azi = rad2deg(azi);
    elev = rad2deg(elev);