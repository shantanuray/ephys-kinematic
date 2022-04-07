function processAniposeEphysBatch(rootdir, savedir, varargin)
    % processAniposeEphysBatch(rootdir, savedir)
    % processAniposeEphysBatch('headfixedreach/',
    %                           'headfixedreach/',
    %                           'FilterAniposeFlag', false,
    %                           'ScoreThresh', 0.05,
    %                           'FixedReachIntervalms', 750);
    % Batch process to:
    % - List all anipose data locations
    % - Load anipose data and filter if necessary
    % - Load ephys data
    % - Segment trials
    % 
    % Default Param Values:
    %   FilterAniposeFlag = false
    %   ScoreThresh = 0.05
    %   MaxGap = 50
    %   FixedReachIntervalms = 750

    % Initialize inputs
    p = readInput(varargin);
    [fixedReachIntervalms, filterAniposeFlag, scoreThresh, maxGap, aniposeDirList] = parseInput(p.Results);

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
        if filterAniposeFlag
            disp('Filtering anipose data')
            [aniposeData] = filterAniposeDataTable(aniposeData, scoreThresh);
            aniposeData = fillmissing(aniposeData,...
                                      'linear',...
                                      'EndValues','nearest',...
                                      'MaxGap', maxGap);
        end
        disp(sprintf('Loading ephys data from %s', anipose_ephys_loc.ephys_loc));
        try
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
            ephysSamplingRate] = loadOEbinary_AT(anipose_ephys_loc.ephys_loc, aniposeData);
            aniposeSamplingRate = 200;
            aniposeNumTS = round(fixedReachIntervalms*aniposeSamplingRate/1000,0);
            ephysNumTS = round(fixedReachIntervalms*ephysSamplingRate/1000,0);
            % Segment data by trial
            trial_list = trial_segmentation(aniposeData,...
                                           solenoid_on,...
                                           spoutContact_on,...
                                           videoFrames_timestamps,...
                                           laserTrig,...
                                           EMG_biceps,...
                                           EMG_triceps,...
                                           EMG_ecu,...
                                           EMG_trap,...
                                           aniposeNumTS,...
                                           ephysNumTS);
            trial_list = getRelativeDistance(trial_list);
            trial_list = getVelocityAcceleration(trial_list, aniposeSamplingRate);
            disp(sprintf('Saving trials for %s', anipose_ephys_loc.label))
            save(fullfile(savedir, strcat(anipose_ephys_loc.label, '.mat')), 'trial_list');
        catch
            disp(sprintf('Issue processing %s', aniposeDirList{i}))
        end
    end
    %% Read input
    function p = readInput(input)
        %   - FilterAniposeFlag     Default - false
        %   - ScoreThresh           Default - 0.05 
        %   - MaxGap:               Default - 50
        p = inputParser;
        defaultFilterAniposeFlag = false;
        defaultScoreThresh = 0.05 ;
        defaultMaxGap = 50;
        defaultFixedReachIntervalms = 750;
        defaultAniposeDirList = {};

        addParameter(p,'FilterAniposeFlag',defaultFilterAniposeFlag, @islogical);
        addParameter(p,'ScoreThresh',defaultScoreThresh, @isnumeric);
        addParameter(p,'MaxGap',defaultMaxGap, @isnumeric);
        addParameter(p,'FixedReachIntervalms',defaultFixedReachIntervalms, @isnumeric);
        addParameter(p,'AniposeDirList',defaultAniposeDirList, @iscell);
        parse(p, input{:});
    end

    function [fixedReachIntervalms, filterAniposeFlag, scoreThresh, maxGap, aniposeDirList] = parseInput(p)
        fixedReachIntervalms = p.FixedReachIntervalms;
        filterAniposeFlag = p.FilterAniposeFlag;
        scoreThresh = p.ScoreThresh;
        maxGap = p.MaxGap;
        aniposeDirList = p.AniposeDirList;
    end
end