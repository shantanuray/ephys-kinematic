function [EMG_trap,...
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
          aniposeData] = loadOEbinary_AT(oebin_file, aniposeData);

if nargin < 2
   % load anipose data
   anipose_dir = uigetdir('.', 'get anipose dir');
   aniposeData = importAnipose3dData(anipose_dir);
end;
if nargin < 1
   % Get oebin location
   [filename, pathname] = uigetfile('*.oebin', 'Pick oebin file');
   oebin_file = fullfile(pathname, filename);
end

%% Load using Open Ephys functions
contData = load_open_ephys_binary(oebin_file, 'continuous', 1);
eventData = load_open_ephys_binary(oebin_file, 'events', 1);
%spikeData = load_open_ephys_binary(oebin_file, 'spikes', 1);

% Calculate time in seconds of ephys data
timeInSeconds = double(contData.Timestamps)./contData.Header.sample_rate;

%%videoFrames_timestamps,% videoFrame_timestamps is the time on the Ephys data which has video 
%% Get frame timestamps
% camFrameTrig is same as anipose data samples
camFrameTrig = contData.Data(39,:).*contData.Header.channels(39).bit_volts;  % AI7 - Camera frame clock
[pks, camFrameTrig_idx] = findpeaks(camFrameTrig, 'MinPeakDistance', 50, 'MinPeakHeight', 3);
camFrameTrig_samplesFromPrev = diff([0 camFrameTrig_idx]);
% Find when the video recording started
videoStart = find(camFrameTrig_samplesFromPrev > 200);
videoStart = find(camFrameTrig_samplesFromPrev);

%totalFrames=length(pks);
% Set videoStart as the first value (frame 1)
totalFrames=height(aniposeData);
% use to reference anipose data
videoFrames_idx = camFrameTrig_idx(videoStart:videoStart+totalFrames-1);
% use this to reference ephys data
videoFrames_timestamps = contData.Timestamps(videoFrames_idx);
videoFrames_timeInSeconds = timeInSeconds(videoFrames_idx);

%% Sampling info
samplingRate = contData.Header.sample_rate;
nSamples=length(contData.Data);
%% Fetch and rename analog variables, then re-scale units to volts
%ADC1 = contData.Data(33,:);
EMG_trap = contData.Data(34,:).*contData.Header.channels(34).bit_volts;
EMG_biceps = contData.Data(36,:).*contData.Header.channels(36).bit_volts;
EMG_triceps = contData.Data(35,:).*contData.Header.channels(35).bit_volts;
EMG_ecu = contData.Data(37,:).*contData.Header.channels(37).bit_volts;
%ADC6 = contData.Data(38,:);
frameTrig = contData.Data(39,:).*contData.Header.channels(39).bit_volts;
laserTrig = contData.Data(40,:).*contData.Header.channels(40).bit_volts;
fs=30000;

if height(aniposeData)>length(frameTrig)
   aniposeData=aniposeData(1:length(frameTrig),:);
end

%% Fetch and rename digital input events
tone_on = eventData.Timestamps(eventData.Data == 2);
tone_off = eventData.Timestamps(eventData.Data == -2);
solenoid_on = eventData.Timestamps(eventData.Data == 4);
solenoid_off = eventData.Timestamps(eventData.Data == -4);
perchContact_on = eventData.Timestamps(eventData.Data == 6);
perchContact_off = eventData.Timestamps(eventData.Data == -6);
spoutContact_on = eventData.Timestamps(eventData.Data == 8);
spoutContact_off = eventData.Timestamps(eventData.Data == -8);