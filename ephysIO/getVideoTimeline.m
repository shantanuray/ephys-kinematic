function videoFrames = getVideoTimeline(oebin_file, ephysInfo, totalFrames, videoSamplingRate)
    % Get video frame indexing and timing information from ephys recording
    %
    % videoFrames = getVideoTimeline(oebin_file, ephysInfo, totalFrames, videoSamplingRate);
    %
    % Processes oebin_file and video frame timing information to sync kinematic data with EMG data
    % 
    % Inputs:
    %   - oebin_file
    %   - ephysInfo: struct() with ephys recording basic info (see getEphysRecordingInfo)
    %   - totalFrames: Ephys recordings are generally done continuously with behavioral experiments interpliced. Use
    %                maxSamples of truncate EMG data to kinematic recording
    % Output:
    %   - emgData: struct()
    %       - samplingRate

    % Note: Passing oebin_file instead of raw data (esp. contData) because MTALB seems to be passing by value and then not releasing memory
    % Loading it within the functon seems to be optimizing the memory consumption for raw data
    % contData has recordings for entire time period over several channels and floating point data, hence is quite large

    contData = load_open_ephys_binary(oebin_file, 'continuous', 1);
    if nargin < 3
        totalFrames = nan;
    end
    if nargin < 4
        videoSamplingRate = 200;
    end

    videoFrames.samplingRate = videoSamplingRate;
    
    %% Get frame timestamps
    % frameTrig is same as anipose data samples
    frameTrig = contData.Data(39,:).*contData.Header.channels(39).bit_volts;% AI7 - Camera frame clock
    
    [pks, frameTrig_idx] = findpeaks(frameTrig, 'MinPeakDistance', 50, 'MinPeakHeight', 3);
    % Transposing frameTrig_idx to be in line with other timeline vectors
    frameTrig_idx = frameTrig_idx';
    frameTrig_samplesFromPrev = diff([0; frameTrig_idx]);
    % Find when the video recording started
    videoFrames.start = find(frameTrig_samplesFromPrev > 200);
    if isempty(videoFrames.start)
        % Set videoFrames.start as the first value (frame 1)
        videoFrames.start = 1;
    end
    
    % Truncate video to a pre-decided length such as behavioral data available
    % use to reference kinematic data available
    videoFrames.frameIdx = frameTrig_idx(videoFrames.start:min(length(frameTrig_idx), videoFrames.start+totalFrames-1));
    % videoFrame_timestamps is the time on the Ephys data which has video 
    videoFrames.timestamps = contData.Timestamps(videoFrames.frameIdx);
    videoFrames.totalFrames = length(videoFrames.frameIdx);
    % Calculate time in seconds wrt ephys data
    videoFrames.timeInSeconds = ephysInfo.timeInSeconds(videoFrames.frameIdx);
    contData = [];
end