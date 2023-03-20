function ephysInfo = getEphysRecordingInfo(oebin_file)
    % Get basic information about ephys recording
    %
    % ephysInfo = getEphysRecordingInfo(oebin_file)
    %
    % Processes oebin_file and extracts basic metadata about ephys recording
    % 
    % Inputs:
    %   - oebin_file
    % Output:
    %   - ephysInfo: struct()
    %        - ephysSamplingRate
    %        - nSamples
    %        - contDataTimestamps
    %        - eventDataTimestamps
    %        - timeInSeconds

    % Note: Passing oebin_file instead of raw data (-  contData) because MTALB seems to be passing by value and then not releasing memory
    % Loading it within the functon seems to be optimizing the memory consumption for raw data
    % contData has recordings for entire time period over several channels and floating point data, hence is quite large
    
    %% Load using Open Ephys functions
    eventData = load_open_ephys_binary(oebin_file, 'events', 1);
    contData = load_open_ephys_binary(oebin_file, 'continuous', 1);

	%% Sampling info
	ephysInfo.ephysSamplingRate = contData.Header.sample_rate;
	ephysInfo.nSamples = length(contData.Data);
	ephysInfo.contDataTimestamps = contData.Timestamps;
	ephysInfo.eventDataTimestamps = eventData.Timestamps;
	ephysInfo.timeInSeconds = double(contData.Timestamps)./ephysInfo.ephysSamplingRate;

    % Force MATLAB to empty memory
	eventData = []
	contData = [];
end