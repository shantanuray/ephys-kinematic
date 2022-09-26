function marker_idx = getTrialMarkerID(trial, marker)
	% marker_idx = getTrialMarkerID(trial, marker);
	% Input:
	%	- marker: marker name
	marker_idx = find(contains(trial.('markerNames'), marker));
	assert(length(marker_idx) == 1, sprintf('getTrialMarkerID:%s:%s missing', trial.trialName, marker));
