%% Use this script to run kinematic & ephys data extraction and trial segmentatio

%% Note: Please make sure to add these folders to MATLAB path
%% addpath ~/projects/ephys-kinematic
%% addpath ~/projects/npy-matlab/npy-matlab

% Get root directory with all of the anipose and ephys data
% For auto-discovery of data within root_dir, the folder structure is assumed to be:
% root_dir/ (eg. /mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A11-3
% disp('Choose the root directory with all of the anipose and ephys data'), this is typically the animal folder 
% root_dir = uigetdir('.', 'Choose root directory with all of the anipose and ephys data');% animal directory
root_dir = "/Volumes/dcn_emg_behavior/Ayesha/A11-1/temp/";

% Get save directory
% disp('Choose common location to save trials')
% save_dir = uigetdir('.', 'Choose common location to save trials');% common folder for all mat files 
save_dir = "/Volumes/dcn_emg_behavior/Ayesha/A11-1/temp/data";

% Filter parameters
scoreThresh = 0.05; % choose based on error 
fillMissingGapSize = 50;
filterThresholdFlag = false;
scoreThresh = 0.05;
filterFlag= true;
fixedReachIntervalms = 1500; % ms
%% Time duration for extracting fixed trial data in ms
%% startEvents
%%   {'solenoid_on'}
%%   {'tone_on'}
%%   {'solenoid_on', 'tone_on'}
startEvents = {'tone_on'};
% Pass parameters to batch function
% This will extract anipose, ephys data for all data folders within root_dir and save the result in save_dir
%_1 includes new trial segmentation
processAniposeEphysBatchStartEvent_1(root_dir, save_dir,...
                                   'startEvents', startEvents,...
                                   'filterThresholdFlag', filterThresholdFlag,...
                                   'filterFlag',filterFlag,...
                                   'scoreThresh', scoreThresh,...
                                   'maxGap', fillMissingGapSize,...
                                   'fixedReachIntervalms', fixedReachIntervalms);
