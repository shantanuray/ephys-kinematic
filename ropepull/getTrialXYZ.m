function xyz = getTrialXYZ(trial, markerName)
	% xyz = getTrialXYZ(trial);
	% xyz = getTrialXYZ(trial, 'nose');
	% 
	xyzField = 'trialXYZ';
	assert(find(contains(fieldnames(trial), xyzField)), sprintf('%s missing', xyzField));
	xyz = trial.(xyzField);
	if nargin == 2
	    markerID = getTrialMarkerID(trial, markerName);
	    assert(length(markerID) > 0, sprintf('%s missing', markerName));
		xyz = xyz(:, markerID, :);
		xyz = squeeze(xyz);
	end