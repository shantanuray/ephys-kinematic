function xyz = getTrialXYZ(trial, markerName)
	% xyz = getTrialXYZ(trial);
	% xyz = getTrialXYZ(trial, 'nose');
	% 
	xyzField = 'trialXYZ';
	assert(~isempty(find(contains(fieldnames(trial), xyzField))), sprintf('getTrialXYZ:%s:%s missing', trial.trialName, xyzField));
	xyz = trial.(xyzField);
	if nargin == 2
	    markerID = getTrialMarkerID(trial, markerName);
	    assert(~isempty(markerID), sprintf('getTrialXYZ:%s: %s missing', trial.trialName, markerName));
		xyz = xyz(:, markerID, :);
		xyz = squeeze(xyz);
	end