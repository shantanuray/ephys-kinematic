function processAniposeEphysBatchStartEvent(rootdir, savedir, varargin)
    % processAniposeEphysBatchStartEvent(rootdir, savedir)
    % processAniposeEphysBatchStartEvent('headfixedreach/',
    %                           'headfixedreach/',
    %                           'filterThresholdFlag', false,
    %                           'scoreThresh', 0.05,
    %                           'filterFlag', true,
    %                           'signalFilter', passbandloFilt,
    %                           'fixedReachIntervalms', 750);
    % Batch process to:
    % - List all anipose data locations
    % - Load anipose data and filter if necessary
    % - Load ephys data
    % - Segment trials
    % 
    % Default Param Values:
    %   filterThresholdFlag = false
    %   scoreThresh = 0.05
    %   filterFlag = true
    %   signalFilter = designfilt('lowpassiir',...
    %                                 'FilterOrder',8, ...
    %                                 'PassbandFrequency',50,...
    %                                 'PassbandRipple',0.2,...
    %                                 'SampleRate',200);
    %   fixedReachIntervalms = 750
    %   aniposeDirList = {}
    %   startEvents = {'solenoid_on'}
    %   filterEMG = false

    % Initialize inputs
    p = readInput(varargin);
    [fixedReachIntervalms,...
    filterThresholdFlag, scoreThresh,...
    filterFlag, signalFilter,...
    maxGap, aniposeDirList, startEvents, filterEMG] = parseInput(p.Results);

    % Get list of all dir with anipose data
    indicator = 'pose-3d';
    if isempty(aniposeDirList)
        disp('Extracting video locations')
        aniposeDirList = listAniposeDir(rootdir, indicator);
    end
    disp(sprintf('Located %d locations', length(aniposeDirList)))

    for i = 1:length(aniposeDirList)
        disp(sprintf('Initiating processing %s', aniposeDirList{i}))
        % TODO:anipose_ephys_loc.anipose_dir is returning with the indicator string at the end
        % Example: headfixedwaterreach/A1-2/AT_A1-2_2021-08-20_13-06-28_hfwr_LightOFF_video/pose-3d
        % We need one folder up, i.e. headfixedwaterreach/A1-2/AT_A1-2_2021-08-20_13-06-28_hfwr_LightOFF_video
        dir_sep = strfind(aniposeDirList{i}, indicator);
        if isempty(dir_sep)
            dir_sep = length(aniposeDirList{i});
        else
            dir_sep = dir_sep - 2;
        end
        aniposedir_root = aniposeDirList{i}(1:dir_sep);
        % Get anipose and ephys data location
        anipose_ephys_loc = extractAniposeEphysDir(aniposedir_root);
        % Load anipose data
        disp(sprintf('Loading anipose data from %s', aniposedir_root))
        aniposeData = importAnipose3dData(aniposedir_root);
        if filterThresholdFlag
            disp('Filtering anipose data with confidence score < ScoreThresh')
            % Filter out data based on anipose score in comparison to ScoreThresh
            [aniposeData] = filterAniposeDataTable(aniposeData, scoreThresh);
            % aniposeData = fillmissing(aniposeData,...
            %                           'linear',...
            %                           'EndValues','nearest',...
            %                           'MaxGap', maxGap);
            % R2020b and earlier does not have MaxGap option
            aniposeData = fillmissing(aniposeData,...
                                      'linear',...
                                      'EndValues','nearest');
        end
        if filterFlag
            disp('Filtering anipose signal data')
            % Find columns in aniposeData with xyz data for filtering
            xyzColPos = findColPos(aniposeData, {'_x', '_y','_z'});
            aniposeDataArray = table2array(aniposeData(:, xyzColPos));
            aniposeDataArray = filtfilt(passbandloFilt, aniposeDataArray);
            aniposeData(:, xyzColPos) = array2table(aniposeDataArray);
        end
        
        disp(sprintf('Loading ephys data from %s', anipose_ephys_loc.ephys_loc));
        if length(anipose_ephys_loc.ephys_loc)>0
            % Load ephys data
            [EMG_trap,...
            EMG_biceps,...
            EMG_triceps,...
            EMG_ecu,...
            frameTrig,...
            laserTrig,...
            tone_on,...
            tone_off,...
            solenoid_on,...
            solenoid_off,...
            perchContact_on,...
            perchContact_off,...
            spoutContact_on,...
            spoutContact_off,...
            videoFrames_timestamps,...
            videoFrames_timeInSeconds,...
            aniposeData,...
            ephysSamplingRate,...
            contDataTimestamps,...
            eventDataTimestamps] = loadOEbinary_AT(anipose_ephys_loc.ephys_loc, aniposeData);
            aniposeSamplingRate = 200;
            aniposeNumTS = round(fixedReachIntervalms*aniposeSamplingRate/1000,0);
            ephysNumTS = round(fixedReachIntervalms*ephysSamplingRate/1000,0);
            % Segment data by trial
            for evnt_idx = 1:length(startEvents)
                startEvent = startEvents{evnt_idx};
                startTrialTrigger = eval(startEvent);
                disp(sprintf('Find events for trigger %s', startEvent));
                if isempty(startTrialTrigger)
                    disp(sprintf('Unable to find data for %s. Skipping ...', startEvent));
                else
                    trial_list = trial_segmentation(aniposeData,...
                                                   startTrialTrigger,...
                                                   spoutContact_on,...
                                                   perchContact_on, perchContact_off,...
                                                   videoFrames_timestamps,...
                                                   laserTrig,...
                                                   EMG_biceps,...
                                                   EMG_triceps,...
                                                   EMG_ecu,...
                                                   EMG_trap,...
                                                   aniposeNumTS,...
                                                   ephysNumTS,...
                                                   contDataTimestamps,...
                                                   ephysSamplingRate,...
                                                   filterEMG);
                    processLabels = {'aniposeData_fixed',...
                                     'aniposeData_first_sc',...
                                     'aniposeData_last_sc'};
                    trial_list = getRelativeDistance(trial_list, processLabels);
                    processLabels = {'aniposeData_fixed_relative',...
                                     'aniposeData_first_sc_relative',...
                                     'aniposeData_last_sc_relative'};
                    trial_list = getVelocityAcceleration(trial_list, aniposeSamplingRate, processLabels);
                    switch lower(startEvent)
                    case 'solenoid_on'
                        trialList_solenoid_on = trial_list;
                        trialList_varName = 'trialList_solenoid_on';
                    case 'tone_on'
                        trialList_tone_on = trial_list;
                        trialList_varName = 'trialList_tone_on';
                    otherwise
                        trialList_varName = 'trial_list';
                    end
                    disp(sprintf('Saving %s trials for %s', startEvent, anipose_ephys_loc.label));
                    if filterThresholdFlag
                        saveFilename = strcat(anipose_ephys_loc.label, '_',  startEvent, '_filtered.mat');
                    else
                        saveFilename = strcat(anipose_ephys_loc.label, '_',  startEvent, '.mat');
                    end
                    save(fullfile(savedir, saveFilename), trialList_varName,...
                        'tone_on', 'tone_off',...
                        'solenoid_on', 'solenoid_off',...
                        'perchContact_on', 'perchContact_off',...
                        'spoutContact_on', 'spoutContact_off',...
                        'videoFrames_timestamps',...
                        'contDataTimestamps', 'eventDataTimestamps',...
                        'ephysSamplingRate');
                end
            end
        else
            disp(sprintf('Could not find ephys data. Missing %s', anipose_ephys_loc.ephys_loc));
        end
    end
    %% Read input
    function p = readInput(input)
        p = inputParser;
        defaultThresholdFilterFlag = false;
        defaultFilterFlag = true;
        defaultFilter = designfilt('lowpassiir',...
                                   'FilterOrder',8, ...
                                   'PassbandFrequency',50,...
                                   'PassbandRipple',0.2,...
                                   'SampleRate',200);
        defaultScoreThresh = 0.05 ;
        defaultMaxGap = 50;
        defaultFixedReachIntervalms = 750;
        defaultStartEvents = {'solenoid_on', 'tone_on'};
        filterEMG = false;

        addParameter(p,'filterThresholdFlag',defaultThresholdFilterFlag, @islogical);
        addParameter(p,'filterFlag',defaultFilterFlag, @islogical);
        addParameter(p,'signalFilter',defaultFilter);
        addParameter(p,'scoreThresh',defaultScoreThresh, @isnumeric);
        addParameter(p,'maxGap',defaultMaxGap, @isnumeric);
        addParameter(p,'fixedReachIntervalms',defaultFixedReachIntervalms, @isnumeric);
        addParameter(p,'startEvents',defaultStartEvents, @iscell);
        addParameter(p,'filterEMG',filterEMG, @islogical);
        parse(p, input{:});
    end

    function [fixedReachIntervalms, filterThresholdFlag, scoreThresh, maxGap, filterFlag, signalFilter, startEvents, filterEMG] = parseInput(p)
        fixedReachIntervalms = p.fixedReachIntervalms;
        filterThresholdFlag = p.filterThresholdFlag;
        scoreThresh = p.scoreThresh;
        maxGap = p.maxGap;
        filterFlag = p.filterFlag;
        signalFilter = p.signalFilter
        aniposeDirList = p.aniposeDirList;
        startEvents = p.startEvents;
        filterEMG = p.filterEMG;
    end
end