%% Use this script to run kinematic & ephys data extraction and trial segmentatio

%% Note: Please make sure to add these folders to MATLAB path
%% addpath ~/projects/ephys-kinematic
%% addpath ~/projects/npy-matlab/npy-matlab

% Get root directory with all of the anipose and ephys data
% For auto-discovery of data within root_dir, the folder structure is assumed to be:
% root_dir/ (eg. /mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A11-3
% Full path example: /mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A11-3/A11-3_2022-02-25_11-59-18_video/pose-3d

% disp('Choose the root directory with all of the anipose and ephys data')
% root_dir = uigetdir('.', 'Choose root directory with all of the anipose and ephys data');% animal directory
root_dir = "/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A34-2/";

% % Get save directory
% disp('Choose common location to save trials')
% save_dir = uigetdir('.', 'Choose common location to save trials');% common folder for all mat files 
save_dir = "/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A34-2/data/filtered";

%% Filter parameters
scoreThresh = 0.05; % choose based on error 
fillMissingGapSize = 50;
filterThresholdFlag = false;
filterFlag= true;
% reply = input(['\nDo you wish filter anipose data??\n\n',...
%             '[Enter/y/Y]    => Yes\n',...
%             '[n/N]          => No    \n'],'s');
% switch lower(reply)
%     case 'y'
%         filterThresholdFlag = true;
%     case 'n'
%         filterThresholdFlag = false;
%     otherwise
%         filterThresholdFlag = true;
% end
% if filterThresholdFlag
%     % Default score threhold
%     reply = input(['\nWhat is filter score threshold??? ',...
%                    sprintf('[Click Enter to use default = (%.2f)]\n', scoreThresh)],...
%                     's');
%     if ~isempty(reply)
%         scoreThresh = str2num(reply);
%     end
% end
scoreThresh = 0.05;
%% Time duration for extracting fixed trial data in ms
fixedReachIntervalms = 1500; % ms
% reply = input(['\nTime interval (ms) to use for extracting fixed trial data?\n\n',...
%             sprintf('[Enter/y/Y]    => %dms (default)\n', fixedReachIntervalms),...
%             'Else enter time interval in ms:\n'],'s');
% if ~isempty(reply)
%     fixedReachIntervalms = str2num(reply);
% end

%% startEvents = Event(s) used for marking start of trial
%% Options:
%%   {'solenoid_on'}
%%   {'tone_on'}
%%   {'solenoid_on', 'tone_on'}
startEvents = {'tone_on'};
% reply = input(['\nWhich event are you using for marking start of trial?\n\n',...
%             '[Enter/1]    => solenoid_on\n',...
%             '2            => tone_on    \n',...
%             '3            => Both solenoid_on and tone_on\n'],'s');
% switch lower(reply)
%     case '1'
%         startEvents = {'solenoid_on'};
%     case '2'
%         startEvents = {'tone_on'};
%     case '3'
%         startEvents = {'solenoid_on','tone_on'};
%     otherwise
%         startEvents = {'solenoid_on'};
% end
% Pass parameters to batch function
% This will extract anipose, ephys data for all data folders within root_dir and save the result in save_dir
processAniposeEphysBatchStartEvent(root_dir, save_dir,...
                                   'startEvents', startEvents,...
                                   'filterThresholdFlag', filterThresholdFlag,...
                                   'filterFlag',filterFlag,...
                                   'scoreThresh', scoreThresh,...
                                   'maxGap', fillMissingGapSize,...
                                   'fixedReachIntervalms', fixedReachIntervalms);
