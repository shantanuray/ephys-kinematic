%% Use this script to run kinmatic & ephys data extraction and trial segmentatio

%% Note: Please make sure to add these folders to MATLAB path
%% addpath ~/projects/ephys-kinematic
%% addpath ~/projects/npy-matlab/npy-matlab

% Get root directory with all of the anipose and ephys data
% For auto-discovery of data within root_dir, the folder structure is assumed to be:
% root_dir/ (eg. /mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/)
%   -> animal_name(s)/ (eg. A11-3/)
%       -> video_folder(s) / (eg. A11-3_2022-02-25_11-59-18_video/)
%           -> pose-3d/ (or angles/) -> This indicates anipose has been run
% Full path example: /mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A11-3/A11-3_2022-02-25_11-59-18_video/pose-3d

disp('Choose the root directory with all of the anipose and ephys data')
root_dir = "/Volumes/dcn_emg_behavior/Ayesha/A11-1/A11-1_2022-04-04_10-36-13_video/";

% Get save directory
disp('Choose common location to save trials')
save_dir = "/Volumes/dcn_emg_behavior/Ayesha/A11-1/A11-1_2022-04-04_10-36-13_video/filtered_50hz";
%% Filter parameters
scoreThresh = 0.05; % choose based on error 
fillMissingGapSize = 50;
filterThresholdFlag = false;
scoreThresh = 0.05;
filterFlag= true;
fixedReachIntervalms = 1500; % ms
startEvents = {'tone_on'};


%% Important: Run this on select folders only,
%% Initialize AniposeDirList and pass that to batch script

% % if root_dir is like '/Volumes/dcn_emg_behavior/Ayesha/A11-1/A11-1_2022-04-04_10-36-13_video', use:
% aniposeDirList = {root_dir}; % Run on root_dir
% % If root_dir is like '/Volumes/dcn_emg_behavior/Ayesha/A11-1' with several _video folders, use:
% aniposeDirList = {}; % Auto-discovers _video within root_dir

%% Pass parameters to batch function
aniposeDirList={root_dir};
processAniposeEphysBatchStartEvent(root_dir, save_dir,...
                                   'aniposeDirList',aniposeDirList,...
                                   'startEvents', startEvents,...
                                   'filterThresholdFlag', filterThresholdFlag,...
                                   'filterFlag',filterFlag,...
                                   'scoreThresh', scoreThresh,...
                                   'maxGap', fillMissingGapSize,...
                                   'fixedReachIntervalms', fixedReachIntervalms);
