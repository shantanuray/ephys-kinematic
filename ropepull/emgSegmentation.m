function emgSegments = emgSegmentation(trial, emgTrialData, varargin)
	% Segment EMG data using segments from kinematic data
	% EMG data - ref: peakData from emg_analysis/emg_ropepull/emgGetPeaksFolder.m
	% 				  EMGData = peakData(trialNum).(channel).(dataType).data

	%% Read & parse inputs
	p = readInput(varargin);
	% 1. For Pre & Postsegments data is stored in the order of peakAnalysisMarkerNames
	% 2. Get EMG channel names
	% 3. Get EMG data as selected in EMGDataType from {'data_raw', 'data_smooth', 'data_filtered'}
	[peakAnalysisMarkerNames, channels, emgDataType] = parseInput(p.Results);

	%% Initialize output
	emgSegments.('trialName') = trial.('trialName');
	ephys_fs = emgTrialData.(channels{1}).('samplingFrequency');
	emgSegments.('EMGSamplingFrequency') = ephys_fs;

	% Retrieve first pull segment from kinematic data and 
	% calculate index for EMG data using ephys sampling freq
	firstPullSegment_ephys_idx_loc = round(trial.('firstPkSegmentT') * ephys_fs);
	emgSegments.('firstPkSegmentT') = trial.('firstPkSegmentT');
	firstPullSegment_ephys_idx = firstPullSegment_ephys_idx_loc(1):firstPullSegment_ephys_idx_loc(2);

	for chan = 1:length(channels)
		emgSegments.(strcat(channels{chan}, '_firstPull')) = emgTrialData.(channels{chan}).(emgDataType).('data')(firstPullSegment_ephys_idx);
	end

	% Retrieve segments for rhythmic section
	emgSegments.('segmentPreT') = trial.('segmentPreT');
	emgSegments.('segmentPost') = trial.('segmentPostT');
	for ms = 1:length(peakAnalysisMarkerNames)
		segmentPre_ephys_idx_loc = round((trial.segmentPreT{1,ms}) * ephys_fs);
		segmentPre_ephys_idx = segmentPre_ephys_idx_loc(1):segmentPre_ephys_idx_loc(2);
		segmentPost_ephys_idx_loc = round((trial.segmentPostT{1,ms}) * ephys_fs);
		segmentPost_ephys_idx = segmentPost_ephys_idx_loc(1):segmentPost_ephys_idx_loc(2);
		for chan = 1:length(channels)
			% TODO: refactor this hack to match handedness between kinematic and EMG data
			if contains(lower(peakAnalysisMarkerNames{ms}), '_left') &&...
				contains(lower(channels{chan}), '_l')
				emgSegments.(strcat(channels{chan}, '_segmentPre')) = emgTrialData.(channels{chan}).(emgDataType).('data')(segmentPre_ephys_idx);
				emgSegments.(strcat(channels{chan}, '_segmentPost')) = emgTrialData.(channels{chan}).(emgDataType).('data')(segmentPost_ephys_idx);
			end
			if contains(lower(peakAnalysisMarkerNames{ms}), '_right') &&...
				contains(lower(channels{chan}), '_r')
				emgSegments.(strcat(channels{chan}, '_segmentPre')) = emgTrialData.(channels{chan}).(emgDataType).('data')(segmentPre_ephys_idx);
				emgSegments.(strcat(channels{chan}, '_segmentPost')) = emgTrialData.(channels{chan}).(emgDataType).('data')(segmentPost_ephys_idx);
			end
		end
	end


	%% Read input
    function p = readInput(input)
        p = inputParser;
    	peakAnalysisMarkerNames = {'hand_left', 'hand_right'};
    	channels = {'bi_R','tri_R','bi_L','tri_L'};
    	emgDataType = 'data_filtered';
    	emgDataTypes = {'data_raw', 'data_smooth', 'data_filtered'};

		addParameter(p,'PeakAnalysisMarkerNames',peakAnalysisMarkerNames, @iscell);
		addParameter(p,'Channels',channels, @iscell);
		addParameter(p,'EMGDataType',emgDataType,...
			@(x) any(validatestring(x, emgDataTypes)));
        parse(p, input{:});
    end

    function [peakAnalysisMarkerNames,...
    	channels,...
    	emgDataType] = parseInput(p)
        peakAnalysisMarkerNames = p.PeakAnalysisMarkerNames;
        channels = p.Channels;
        emgDataType = p.EMGDataType;
    end
end