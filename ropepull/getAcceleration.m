function acceleration = getAcceleration(trial)
	% acceleration = acceleration(trial);
	pathLength = getPathLength(trial);
	fs = trial.('video_fps');
	dt = 1/fs;
	acceleration = diff(getSpeed(trial),1)/dt;
	padZerosCnt = length(pathLength)-length(acceleration);
	acceleration = padZeros(acceleration, padZerosCnt);