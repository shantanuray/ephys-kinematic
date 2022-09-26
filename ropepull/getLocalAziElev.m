function [azi, elev, r] = getLocalAziElev(trial, markerName, varargin)
	% [azi, elev] = getLocalAziElev(trial);
	% [azi, elev] = getLocalAziElev(trial, hand_left');
	%
	% Convert xyz of consecutive points to local direction
	% using cart2sph
	% cart2sph computes azi and elev wrt x-y plane
	% Inputs:
	%	- trial: trial object [mandatory]
	%	- markerName: str [optional] - Default = None
	%	- x_axis, y_axis definitions: str [optional] - Default = 'x', 'y'

	% Initialize inputs
    p = readInput(varargin);
    [x_axis, y_axis] = parseInput(p.Results);
    expectedAxes = {'x','y','z'};
    x_axis_indx = searchStrInCell(expectedAxes,x_axis);
	y_axis_indx = searchStrInCell(expectedAxes,y_axis);
	z_axis_indx = setdiff(1:3, [x_axis_indx, y_axis_indx]);

	% Get trial xyz data
	xyz = getTrialXYZ(trial);
	% Find local relative
	localRelXYZ = diff(xyz, 1);
	localRelX = localRelXYZ(:,:,x_axis_indx);
	localRelY = localRelXYZ(:,:,y_axis_indx);
	localRelZ = localRelXYZ(:,:,z_axis_indx);
	[azi,elev,r] = cart2sph(localRelX,localRelY,localRelZ);

	% Pad zeros because we lose one row from diff
	padZerosCnt = length(xyz)-length(azi);
	azi = padZeros(azi, padZerosCnt);
	elev = padZeros(elev, padZerosCnt);
	r = padZeros(r, padZerosCnt);

	%% Read input
    function p = readInput(input)
        p = inputParser;
        x_axis = 'x';
    	y_axis = 'y';
    	expectedAxes = {'x','y','z'};

        addParameter(p,'x_axis',x_axis,...
        	@(x) any(validatestring(x, expectedAxes)));
        addParameter(p,'y_axis',y_axis,...
        	@(x) any(validatestring(x, expectedAxes)));
        parse(p, input{:});
    end
    function [x_axis, y_axis] = parseInput(p)
        x_axis = p.x_axis;
        y_axis = p.y_axis;
    end
end