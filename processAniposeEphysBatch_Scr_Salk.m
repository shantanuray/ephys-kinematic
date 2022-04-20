%% Use this script to run kinmatic & ephys data extraction and trial segmentation on salk servers
% Enter script parameters prior to running script
% This script does not request for inputs from user

% Add to MATLAB path. Check this with your local directory on the salk server where you running this from
addpath ~/projects/ephys-kinematic
addpath ~/projects/npy-matlab/npy-matlab

root_dir = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/';
% Saving to a new folder initialized to TODAY. Change as necessary
save_dir = fullfile(root_dir, datestr(now, 'yyyy-mm-dd'));
if exist(save_dir, 'dir') ~= 7
    mkdir(save_dir);
end

%% Filter parameters
filterAniposeFlag = false;
scoreThresh = 0.05;
fillMissingGapSize = 50;

%% Time duration for extracting fixed trial data in ms
fixedReachInterval = 750;

% startEvents = Event(s) used for marking start of trial
% Options:
%   {'solenoid_on'}
%   {'tone_on'}
%   {'solenoid_on', 'tone_on'}
startEvents = {'solenoid_on','tone_on'};

% Run batc on select folders only
aniposeDirList = {'/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A11-3/A11-3_2022-02-25_11-59-18_video',...
                  '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A11-2/A11-2_2022-03-21_16-56-10_video'};
% Pass parameters to batch function
processAniposeEphysBatchStartEvent(root_dir, save_dir,...
                                   'AniposeDirList', aniposeDirList, 'StartEvents', startEvents,...
                                   'FilterAniposeFlag', filterAniposeFlag,...
                                   'ScoreThresh', scoreThresh, 'MaxGap', fillMissingGapSize, 'FixedReachInterval', fixedReachInterval);