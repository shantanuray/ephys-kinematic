function processAniposeEphysBatch(varargin)
    % processAniposeEphysBatch('RootDir', 'headfixedreach/A1-2',
    %                           'SaveDir', 'headfixedreach/',
    %                           'FilterAniposeFlag', false,
    %                           'ScoreThresh', 0.05);
    % Batch process to:
    % - List all anipose data locations
    % - Load anipose data and filter if necessary
    % - Load ephys data
    % - Segment trials
    % Default:
    %   FilterAniposeFlag = false
    %   ScoreThresh = 0.05
    %   MaxGap = 50

    % Initialize inputs
    p = readInput(varargin);
    [rootdir, savedir, filterAniposeFlag, scoreThresh, maxGap] = parseInput(p.Results);

    % Get root directory with all of the anipose and ephys data
    if isnan(rootdir)
        disp('Choose the root directory with all of the anipose and ephys data')
        rootdir = uigetdir('.', 'Choose root directory with all of the anipose and ephys data');
    end

    % Get save directory
    if isnan(savedir)
        disp('Choose common location to save trials')
        savedir = uigetdir('.', 'Choose common location to save trials');
    end

    % Get list of all dir with anipose data
    disp('Extracting video locations')
    indicator = 'pose-3d';
    anipose_dir_list = listAniposeDir(rootdir, indicator);
    disp(sprintf('Located %d locations', length(anipose_dir_list)))

    for i = 1:length(anipose_dir_list)
        disp(sprintf('Initiating processing %s', anipose_dir_list{i}))
        % TODO:anipose_ephys_loc.anipose_dir is returning with the indicator string at the end
        % Example: headfixedwaterreach/A1-2/AT_A1-2_2021-08-20_13-06-28_hfwr_LightOFF_video/pose-3d
        % We need one folder up, i.e. headfixedwaterreach/A1-2/AT_A1-2_2021-08-20_13-06-28_hfwr_LightOFF_video
        dir_sep = strfind(anipose_dir_list{i}, indicator);
        if isempty(dir_sep)
            dir_sep = length(anipose_dir_list{i});
        else
            dir_sep = dir_sep - 2;
        end
        aniposedir_root = anipose_dir_list{i}(1:dir_sep);
        % Get anipose and ephys data location
        anipose_ephys_loc = extractAniposeEphysDir(anipose_dir_list{i});
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
        aniposeData] = loadOEbinary_AT(anipose_ephys_loc.ephys_loc, aniposeData);
        % Segment data by trial
        trial_list = trial_segmentation(aniposeData,...
                                       solenoid_on,...
                                       spoutContact_on,...
                                       videoFrames_timestamps,...
                                       laserTrig,...
                                       EMG_biceps,...
                                       EMG_triceps,...
                                       EMG_ecu,...
                                       EMG_trap);
        disp(sprintf('Saving trials for %s', anipose_ephys_loc.label))
        save(fullfile(savedir, strcat(anipose_ephys_loc.label, '.mat')), 'trial_list');
    end
    %% Read input
    function p = readInput(input)
        %   - FilterAniposeFlag     Default - false
        %   - ScoreThresh           Default - 0.05 
        %   - MaxGap:               Default - 50
        %   - RootDir:              Default - '.'
        %   - SaveDir:              Default - '.'
        p = inputParser;
        defaultFilterAniposeFlag = false;
        defaultScoreThresh = 0.05 ;
        defaultMaxGap = 50;
        defaultRootDir = nan;
        defaultSaveDir = nan;

        addParameter(p,'RootDir',defaultRootDir, @ischar);
        addParameter(p,'SaveDir',defaultSaveDir,@ischar);
        addParameter(p,'FilterAniposeFlag',defaultFilterAniposeFlag, @islogical);
        addParameter(p,'ScoreThresh',defaultScoreThresh, @isnumeric);
        addParameter(p,'MaxGap',defaultMaxGap, @isnumeric);
        parse(p, input{:});
    end

    function [rootdir, savedir, filterAniposeFlag, scoreThresh, maxGap] = parseInput(p)
        rootdir = p.RootDir;
        savedir = p.SaveDir;
        filterAniposeFlag = p.FilterAniposeFlag;
        scoreThresh = p.ScoreThresh;
        maxGap = p.MaxGap;
    end
end