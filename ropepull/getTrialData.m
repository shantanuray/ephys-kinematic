function trial = getTrialData(pose_3d, trialName, varargin)
	% trial = getTrialData(pose_3d, trialName, 'video_fs', 200);
	% Create 3D trial data and other related measurements
	%
	% trial = getTrialData(...
	%		pose3d,...
	%		'CFL10_03292022_CNO_16_15-51-41',...
	%		'video_fps', 200,...
	%		'dorsoVentralAxis', 'x',...
	%		'peakMarkerName', 'nose', ...
	%		'baseMarkerNames', {'foot_left', 'foot_right'});

	% Initialize inputs
    p = readInput(varargin);
    [video_fps,...
    	dorsoVentralAxis,...
    	peakMarkerName, baseMarkerNames,...
    	shoulderName, elbowJointName, wristMarkerName,...
    	peakAnalysisMarkerNames, peakSegmentVariables,...
    	markerNames,...
    	maxPeakHeight, minPeakProminence,...
    	retrieveDataFS] = parseInput(p.Results);
    % Init trial info
    trial.trialName = trialName;
    trial.video_fps = video_fps;
    trial.markerNames = markerNames;
    % Get as-is triangulated XYZ data
	trial.trialXYZ = pose_3d;
	% Compute kinematics
	% Get path length between consecutive points of the trial
	trial.pathLength = getPathLength(trial);
	% Get average speed between consecutive points of the trial
	trial.speed = getSpeed(trial);
	% Get acceleration ...
	trial.acceleration = getAcceleration(trial);
	% Get distance along dorsoVentralAxis between midbase of baseMarkerNames to peakMarkerName
	trial.poseHeight = getPoseHeight(trial, baseMarkerNames, peakMarkerName, dorsoVentralAxis);
	% Get distance along lateral axies between midbase of baseMarkerNames to peakMarkerName
	trial.poseLateralDistance = getPoseLateralDistance(trial, baseMarkerNames, peakMarkerName, dorsoVentralAxis);
	% Get local azi and elev between consecutive points of the trial
	[trial.azi, trial.elev] = getLocalAziElev(trial);
	% Get elbow angle
	trial.elbowAngle = getElbowJointAngle(trial, shoulderName, elbowJointName, wristMarkerName);
	% Number of peaks and peak frequency for peakAnalysisMarkerNames
	for m = 1:length(peakAnalysisMarkerNames)
		% Number of peaks in trial and peak frequency
		[trial.(strcat(peakAnalysisMarkerNames{m}, 'NumPeaks')),...
		trial.(strcat(peakAnalysisMarkerNames{m}, 'FreqPeaks'))] = countPeaks(...
			trial,...
			peakAnalysisMarkerNames{m},...
			dorsoVentralAxis,...
			maxPeakHeight,...
			'minPeakProminence', minPeakProminence);
	end
	% Get segment definitions based on Peak analysis for peakAnalysisMarkerNames
	% 1. Get first peak between peakAnalysisMarkerNames and compute segment time stamps
    try
	    [firstPkSegmentT, pkLoc, firstMarker] = getFirstMarker(...
		    trial,...
		    peakAnalysisMarkerNames,...
		    dorsoVentralAxis,...
		    maxPeakHeight,...
		    'minPeakProminence',minPeakProminence);
	    trial.('firstPkSegmentT') = firstPkSegmentT;
        if ~isnan(firstPkSegmentT)
	        firstPkSegmentTS = tsFromTime(firstPkSegmentT, retrieveDataFS);
	        trial.('firstPullMarker') = peakAnalysisMarkerNames{firstMarker};
        else
            firstPkSegmentTS = nan;
            trial.('firstPullMarker') = nan;
        end
	    % 2. Get rhythmic peak definitions for peakAnalysisMarkerNames and compute segment time stamps
	    for m = 1:length(peakAnalysisMarkerNames)
		    [segmentPre{m}, segmentPost{m}] = getSegmentRhythymicPeak(trial, peakAnalysisMarkerNames{m}, dorsoVentralAxis, maxPeakHeight, 'minPeakProminence',minPeakProminence);
		    segmentPreTS{m} = tsFromTime(segmentPre{m}, retrieveDataFS);
		    segmentPostTS{m} = tsFromTime(segmentPost{m}, retrieveDataFS);
	    end
	    trial.('segmentPreT') = segmentPre;
	    trial.('segmentPostT') = segmentPost;
	    % Segment existing data in trial using first pull segment and rhythmic segments
	    for ms =1:length(peakSegmentVariables)
		    % Segment peakSegmentVariables using firstPkSegmentTS
		    trial.(strcat(peakSegmentVariables{ms}, 'FirstPullData')).('data') = getPulls(...
			    trial,...
			    peakSegmentVariables{ms},...
			    firstPkSegmentTS,...
			    trial.('firstPullMarker'));
		    % Segment peakSegmentVariables using segmentPreTS and segmentPostTS
		    for m = 1:length(peakAnalysisMarkerNames)
		    	if ~isnan(segmentPre{m})
				    trial.(strcat(peakSegmentVariables{ms}, 'RhythymicPeakPreV', peakAnalysisMarkerNames{m})).('data') = getPulls(...
					    trial,...
					    peakSegmentVariables{ms},...,
					    segmentPreTS{m},...
					    peakAnalysisMarkerNames{m});
				else
					trial.(strcat(peakSegmentVariables{ms}, 'RhythymicPeakPreV', peakAnalysisMarkerNames{m})).('data') = nan;
				end
				if ~isnan(segmentPost{m})
				    trial.(strcat(peakSegmentVariables{ms}, 'RhythymicPeakPostV', peakAnalysisMarkerNames{m})).('data') = getPulls(...
					    trial,...
					    peakSegmentVariables{ms},...,
					    segmentPostTS{m},...
					    peakAnalysisMarkerNames{m});
				else
					trial.(strcat(peakSegmentVariables{ms}, 'RhythymicPeakPostV', peakAnalysisMarkerNames{m})).('data') = nan;
				end
		    end
        end
    catch ME
    	disp(sprintf('Error processing %s', trial.trialName));
    	disp(sprintf('Error message: %s', ME.message));
    	trial.('firstPullMarker') = nan;
    	trial.('firstPkSegmentT') = nan;
    	trial.('segmentPreT') = nan;
	    trial.('segmentPostT') = nan;
	    for ms =1:length(peakSegmentVariables)
		    % Segment peakSegmentVariables using firstPkSegmentTS
		    trial.(strcat(peakSegmentVariables{ms}, 'FirstPullData')) = nan;
		    % Segment peakSegmentVariables using segmentPreTS and segmentPostTS
		    for m = 1:length(peakAnalysisMarkerNames)
			    trial.(strcat(peakSegmentVariables{ms}, 'RhythymicPeakPreV', peakAnalysisMarkerNames{m})) = nan;
			    trial.(strcat(peakSegmentVariables{ms}, 'RhythymicPeakPostV', peakAnalysisMarkerNames{m})) = nan;
		    end
        end
    end
       

	%% Read input
    function p = readInput(input)
        p = inputParser;
        video_fps = 200;
    	dorsoVentralAxis = 'x';
    	expectedAxes = {'x','y','z'};
    	peakMarkerName = 'nose';
    	baseMarkerNames = {'foot_left', 'foot_right'};
    	shoulderName = 'shoulder_right';
    	elbowJointName = 'elbow_right';
    	wristMarkerName = 'wrist_right';
    	markerNames = {'nose', 'foot_right', 'foot_left', 'hand_right', 'hand_left',...
					   'elbow_right', 'shoulder_right', 'rope_top', 'rope_base',...
					   'wrist_right', 'rope_mid'};
		maxPeakHeight = 0;
		minPeakProminence = 0.2;
		peakAnalysisMarkerNames = {'hand_left', 'hand_right'};
		peakSegmentVariables = {'trialXYZ','pathLength' 'speed', 'acceleration', 'azi', 'elev', 'elbowAngle'};
		retrieveDataFS = 200;

        addParameter(p,'video_fps',video_fps, @isnumeric);
        addParameter(p,'dorsoVentralAxis',dorsoVentralAxis,...
        	@(x) any(validatestring(x, expectedAxes)));
        addParameter(p,'peakMarkerName',peakMarkerName, @ischar);
        addParameter(p,'baseMarkerNames',baseMarkerNames, @iscell);
        addParameter(p,'shoulderName',shoulderName, @ischar);
        addParameter(p,'elbowJointName',elbowJointName, @ischar);
        addParameter(p,'wristMarkerName',wristMarkerName, @ischar);
        addParameter(p,'markerNames',markerNames, @iscell);
        addParameter(p,'maxPeakHeight',maxPeakHeight, @isnumeric);
        addParameter(p,'minPeakProminence',minPeakProminence, @isnumeric);
        addParameter(p,'peakAnalysisMarkerNames',peakAnalysisMarkerNames, @iscell);
        addParameter(p,'peakSegmentVariables',peakSegmentVariables, @iscell);
        addParameter(p,'retrieveDataFS',retrieveDataFS, @isnumeric);
        parse(p, input{:});
    end

    function [video_fps,...
    	dorsoVentralAxis,...
    	peakMarkerName, baseMarkerNames,...
    	shoulderName, elbowJointName, wristMarkerName,...
    	peakAnalysisMarkerNames, peakSegmentVariables,...
    	markerNames,...
    	maxPeakHeight, minPeakProminence,...
    	retrieveDataFS] = parseInput(p)
        video_fps = p.video_fps;
        dorsoVentralAxis = p.dorsoVentralAxis;
        peakMarkerName = p.peakMarkerName;
        shoulderName = p.shoulderName;
        elbowJointName = p.elbowJointName;
        wristMarkerName = p.wristMarkerName;
        baseMarkerNames = p.baseMarkerNames;
        peakAnalysisMarkerNames = p.peakAnalysisMarkerNames;
        peakSegmentVariables = p.peakSegmentVariables;
        markerNames = p.markerNames;
        maxPeakHeight = p.maxPeakHeight;
        minPeakProminence = p.minPeakProminence;
        retrieveDataFS = p.retrieveDataFS;
    end
end