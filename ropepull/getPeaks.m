function [loc, pks, startPullLoc, endPullLoc] = getPeaks(trial, markerName, dorsoVentralAxis, maxPeakThreshold, varargin)
	xyz = getTrialXYZ(trial, markerName);
	expectedAxes = {'x','y','z'};
	dorsoVentralAxisIdx = searchStrInCell(expectedAxes, dorsoVentralAxis);
	dorsoVentralAxisData = xyz(:, dorsoVentralAxisIdx);
	% Get all peaks
	[pks, loc] = findpeaks(dorsoVentralAxisData, varargin{:});
	% Start of the pulling behavior differs from trial to trial
	% At times, the pull may have already initiated before start of trial
	% and at times, the pull may initiate mid-trial
	% PoseHeight was chosen to filter pull peaks
	% PoseHeight is in its max height range during pulling behavior
	% While end/start of pull is reflected by min PoseHeight
	% Find start and end of pulling activity
    startPullLoc = nan;
    endPullLoc = nan;
	if ~isempty(loc)
    	poseHeight = trial.poseHeight; %poseHeight=trial.trialXYZ.(:,nodeIDnose,:); poseHeight=squeeze(poseHeight);poseHeight=trial.poseHeight(:,1,:);
    	maxHeightLoc = find(poseHeight==max(poseHeight));
    	startPullLoc = find(poseHeight(1:maxHeightLoc)==min(poseHeight(1:maxHeightLoc)));
    	startPullLoc = startPullLoc(end);
    	endPullLoc = find(poseHeight(maxHeightLoc:end)==min(poseHeight(maxHeightLoc:end)));
    	endPullLoc = endPullLoc(1)+maxHeightLoc-1;
    	% Use peak locations between start and end
    	pullLoc = (loc>=startPullLoc)&(loc<=endPullLoc);
    	loc = loc(pullLoc);
    	pks = pks(pullLoc);
    	filtMaxPeak = pks<maxPeakThreshold;
    	loc = loc(filtMaxPeak);
    	pks = pks(filtMaxPeak);
    end
end