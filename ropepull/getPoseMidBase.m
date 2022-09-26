function poseMidBaseXYZ = getPoseMidBase(trial, baseMarkerNames)
	% poseMidBaseXYZ = getPoseMidBase(trial, baseMarkerNames);
	% TODO: Ayesha to put in explanation
	% midBase = mid point on each axis between markers = [(x2-x1)/2, (y2-y1)/2, (z2-z1)/2] + [x1, y1, z1]
	% baseMarkerNames = cell array of length = 2 Default = {'left_foot', 'right_foot'}
	% Assumption: baseMarkerNames are ordered such that the markers are sorted by the lateral axis
	if nargin<2
		baseMarkerNames = {'foot_left', 'foot_right'};
	end
	for i = 1:length(baseMarkerNames)
		baseMarkerXYZ{i} = getTrialXYZ(trial, baseMarkerNames{i});
	end
	poseMidBaseXYZ = (baseMarkerXYZ{2} -...
				  	  baseMarkerXYZ{1})/2 + baseMarkerXYZ{1};
	poseMidBaseXYZ = squeeze(poseMidBaseXYZ);