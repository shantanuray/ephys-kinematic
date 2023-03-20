function [triaListKinematic, triaListEMG] = getReachesSpoutContactfromFile(aniposedir_root, ephys_loc, startTrialTriggerLabel, filterKinematicThresholdFlag, scoreThresh, maxGap, filterKinematicFlag, kinematicSignalFilter, fixedReachIntervalms, videoSamplingRate)
	% Script to extract kinematic and EMG data for reach segments by spout contact. 
	% - Extract ephys recording metadata such as basic info, events as well as EMG data
	% - Processes anipose dir to get kienematic data
	% - Using event data and reach information, get spout contact information to segment trials
	% - Segment kinematic and EMG data based on reach estimates from sout contact
	% 
    % [triaListKinematic, triaListEMG] = getReachesSpoutContactfromFile(
    %							'headfixedreach/',...
    %                           'headfixedreach/',...
    %							'startTrialTriggerLabel', 'tone_on',...
    %                           'filterKinematicThresholdFlag', false,...
    %                           'filterKinematicFlag', true,...
    %                           'fixedReachIntervalms', 750);
    % Mandatory inputs:
    % 	- 
    % 
    % Optional inputs and default values:
    %   - startTrialTriggerLabel = 'tone_on'
    %   - filterKinematicThresholdFlag = false
    %   - scoreThresh = 0.05
    %	- maxGap = 
    %   - filterKinematicFlag = true
    %   - kinematicSignalFilter = designfilt('lowpassiir',...
    %                                 'FilterOrder',8, ...
    %                                 'PassbandFrequency',50,...
    %                                 'PassbandRipple',0.2,...
    %                                 'SampleRate',200);
    %   - fixedReachIntervalms = 750
    %   - filterEMGFlag = false
    %
    % Outputs:
    % 	- triaListKinematic: struct() array with trial list based on spout contact with reach segmentation info and corresponding kinematic data
    % 	- triaListEMG: struct() array with with trial list based on spout contact with corresponding EMG data

    % Initialize inputs
    p = readInput(varargin);

    [startTrialTriggerLabel, fixedReachIntervalms,...
    filterKinematicThresholdFlag, scoreThresh, maxGap,...
    filterKinematicFlag, kinematicSignalFilter,...
    filterEMGFlag] = parseInput(p.Results);

	% Load anipose data
	disp(sprintf("Loading anipose data from %s", aniposedir_root))
	aniposeData = importAnipose3dData(aniposedir_root);
	if filterKinematicThresholdFlag
	    disp(sprintf("Filtering anipose data with confidence score < %0.2f", scoreThresh))
	    % Filter out data based on anipose score in comparison to ScoreThresh
	    [aniposeData] = filterAniposeDataTable(aniposeData, scoreThresh);
	    % aniposeData = fillmissing(aniposeData,...
	    %                           "linear",...
	    %                           "EndValues","nearest",...
	    %                           "MaxGap", maxGap);
	    % R2020b and earlier does not have MaxGap option
	    aniposeData = fillmissing(aniposeData,...
	                             "makima",...
	                             "EndValues","nearest",...
	                             "MaxGap", maxGap);
	end
	if filterKinematicFlag
	    disp("Filtering anipose signal data")
	    % Find columns in aniposeData with xyz data for filtering
	    xyzColPos = findColPos(aniposeData, {"_x", "_y","_z"});
	    aniposeDataArray = table2array(aniposeData(:, xyzColPos));
	    % workaround filtfilt doesnt take NaN values so all NaN is set to zero
	    aniposeDataArray(find(isnan(aniposeDataArray))) = 0.0;
	    aniposeDataArray = filtfilt(kinematicSignalFilter, aniposeDataArray);
	    aniposeData(:, xyzColPos) = array2table(aniposeDataArray);
	end
    % Init num samples to truncate ephys data and to sync the two data streams
	kinNumSamples = height(aniposeData);

	disp(sprintf("Loading ephys data from %s", ephys_loc));
	% Get ephys recording basic info
    ephysInfo = getEphysRecordingInfo(ephys_loc);
    % Read event data from ephys
    eventData = getEventDataFromEphys(oebin_file);
    % Get reach segmentation info based on spout contact
	reachesSpoutContact = getReachesSpoutContact(ephys_loc, startTrialTriggerLabel, kinNumSamples, fixedReachIntervalms, videoSamplingRate);
	
    % Get kinematic and EMG data for each trial and save as trial list
    for trialIdx = 1:length(reachesSpoutContact)
		trialKinematicData = getTrialKinematicData(...
								aniposeData,...
								reachesSpoutContact(trialIdx),...
								eventData,...
								ephysInfo,...
								videoSamplingRate,...
								fixedReachIntervalms);
		for channelLabel = {"bicep", "tricep", "trap", "ecu"}
			trialEMGData.(channelLabel) = getTrialEMGChannelData(...
                                            emgChannelData,...
											channelLabel,...
											ephysInfo,...
											reachesSpoutContact(trialIdx),...
											fixedReachIntervalms);
		end
        % Save trial ID in trial kinematic and EMG data
        triaListKinematic(trialIdx).('trialId') = trialIdx;
        triaListEMG(trialIdx).('trialId') = trialIdx;
        % Below is a hack to save a struct array instead of an array of structs
		fn_reach = fieldnames(trialKinematicData);
        fn_kin = fieldnames(trialKinematicData);
		for f =1:length(fn_reach)
			triaListKinematic(trialIdx).(fn_reach{f}) = trialKinematicData.(fn_reach{f});
		end
		for f =1:length(fn_kin)
			triaListKinematic(trialIdx).(fn_kin{f}) = trialKinematicData.(fn_kin{f});
		end
		fn_emg = fieldnames(trialEMGData.(channelLabel));
		for channelLabel = {"bicep", "tricep", "trap", "ecu"}
			for f =1:length(fn_emg)
				triaListEMG(trialIdx).(channelLabel).(fn_emg{f}) = trialEMGData.(channelLabel).(fn_emg{f});
			end
		end
	end

	%% Read input
    function p = readInput(input)
        p = inputParser;
        defaultThresholdFilterFlag = false;
        defaultScoreThresh = 0.05 ;
        defaultMaxGap = 50;
        defaultFilterFlag = true;
        defaultFilter = designfilt('lowpassiir',...
                                   'FilterOrder',8, ...
                                   'PassbandFrequency',50,...
                                   'PassbandRipple',0.2,...
                                   'SampleRate',200);
        defaultFixedReachIntervalms = 750;
        defaultStartEvents = 'tone_on';

        addParameter(p,'filterKinematicThresholdFlag', defaultThresholdFilterFlag, @islogical);
        addParameter(p,'filterKinematicFlag', defaultFilterFlag, @islogical);
        addParameter(p,'kinematicSignalFilter', defaultFilter);
        addParameter(p,'scoreThresh', defaultScoreThresh, @isnumeric);
        addParameter(p,'maxGap', defaultMaxGap, @isnumeric);
        addParameter(p,'fixedReachIntervalms', defaultFixedReachIntervalms, @isnumeric);
        addParameter(p,'startTrialTriggerLabel', defaultStartEvents, @isstr);
        addParameter(p,'filterEMGFlag', false, @islogical);
        parse(p, input{:});
    end

    function [startTrialTriggerLabel, fixedReachIntervalms, filterKinematicThresholdFlag, scoreThresh, maxGap, filterKinematicFlag, kinematicSignalFilter, filterEMGFlag] = parseInput(p)
        startTrialTriggerLabel = p.startTrialTriggerLabel;
        fixedReachIntervalms = p.fixedReachIntervalms;
        filterKinematicThresholdFlag = p.filterKinematicThresholdFlag;
        scoreThresh = p.scoreThresh;
        maxGap = p.maxGap;
        filterKinematicFlag = p.filterKinematicFlag;
        kinematicSignalFilter = p.kinematicSignalFilter;
        filterEMGFlag = p.filterEMGFlag;
    end
end