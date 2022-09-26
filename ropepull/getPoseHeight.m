function poseHeight = getPoseHeight(trial, baseMarkerNames, peakMarkerName, dorsoVentralAxis)
	% poseHeight = getPoseHeight(trial, baseMarkerNames, peakMarkerName, dorsoVentralAxis)
	% poseHeight = getPoseHeight(trial, baseMarkerNames, peakMarkerName)
	% Inputs:
	%	- trial: TrialData
	%	- baseMarkerNames: cell arra of length = 2 eg. {'left_foot', 'right_foot'}
	%	- peakMarkerName: string Default = 'nose'
	%   - dorsoVentralAxis: str = 'x'

	% TODO: Ayesha to put in explanation
	% midBase = mid point on each axis between markers = [(x2-x1)/2, (y2-y1)/2, (z2-z1)/2]
	% baseMarkerNames = cell arra of length = 2 {'left_foot', 'right_foot'}
	% peakMarkerName = string = 'nose'
	% PoseHeight = absolute distance only along the dorso-ventral axis of peakMarkerName wrt poseMidBase
	% Assumption baseMarkerNames is ordered such that the markers is sorted by the lateral axis
	if nargin < 4
		dorsoVentralAxis = 'x';
	end
	dorsoVentralAxisIndx = searchStrInCell({'x','y','z'}, dorsoVentralAxis);
	assert(length(dorsoVentralAxisIndx)>0, sprintf('%s missing', dorsoVentralAxis))
	if nargin < 3
		peakMarkerName = 'nose';
	end
	if nargin<2
		baseMarkerNames = {'foot_left', 'foot_right'};
	end
	% Get xyz of mid base (mid base of left foot - right foot)
	poseMidBaseXYZ = getPoseMidBase(trial, baseMarkerNames);
	% Get xyz of peak marker (nose)
	peakMarkerXYZ = getTrialXYZ(trial, peakMarkerName);
	% Get distance along the dorso-ventral axis
	poseHeight = abs(peakMarkerXYZ(:, dorsoVentralAxisIndx) - poseMidBaseXYZ(:, dorsoVentralAxisIndx));
