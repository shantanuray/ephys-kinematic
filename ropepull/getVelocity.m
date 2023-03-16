function velocity = getVelocity(trial,markerName)
	%velocity=getVelocity(trial)
	% uses matlab gradient to calculate velocity
    trialXYZ=getTrialXYZ(trial);
	fs = getSamplingFrequency(trial, 'video_fps');
	velocity=diff(trialXYZ,1,1)*fs;
	padZerosCnt = length(trialXYZ)-length(velocity);
	velocity = padZeros(velocity, padZerosCnt);
	

if nargin == 2
      markerID = getTrialMarkerID(trial, markerName);
	    assert(~isempty(markerID), sprintf('getVelocity:%s: %s missing', trial.trialName, markerName));
		velocity = velocity(:, markerID,:);
		velocity = squeeze(velocity);
end