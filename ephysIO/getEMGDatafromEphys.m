function emgData = getEMGDatafromEphys(oebin_file, maxSamples);
    % Get EMG Data from ephys recording. 
    %
    % emgData = getEMGDatafromEphys(oebin_file, maxSamples);
    %
    % Processes oebin_file and extracts EMG data for each of the recorded channels and returns struct with metadata and channel data
    % 
    % Inputs:
    %   - oebin_file
    %   - maxSamples: Ephys recordings are generally done continuously with behavioral experiments interpliced. Use
    %                maxSamples of truncate EMG data to kinematic recording
    % Output:
    %   - emgData: struct()
    %       - samplingRate
    %       - data: struct() with EMG data for each channel
    %           - bicep
    %           - tricep
    %           - trap
    %           - ecu

    % Note: Passing oebin_file instead of raw data (esp. contData) because MTALB seems to be passing by value and then not releasing memory
    % Loading it within the functon seems to be optimizing the memory consumption for raw data
    % contData has recordings for entire time period over several channels and floating point data, hence is quite large

    %% Load using Open Ephys functions
    contData = load_open_ephys_binary(oebin_file, 'continuous', 1);

    % Bug in OpenEphys when stopping record that adds 4096 zeros at the end -- need to update GUI to v0.5.5.3
    if nargin >= 2
        contData.Data = contData.Data(:,1:maxSamples);
    end
    %% Sampling info
    emgData.samplingRate = contData.Header.sample_rate;
    
    %% Fetch and rename analog variables, then re-scale units to volts
    %ADC1 = contData.Data(33,:);
    emgData.data.trap = contData.Data(34,:).*contData.Header.channels(34).bit_volts;
    emgData.data.biceps = contData.Data(36,:).*contData.Header.channels(36).bit_volts;
    emgData.data.triceps = contData.Data(35,:).*contData.Header.channels(35).bit_volts;
    emgData.data.ecu = contData.Data(37,:).*contData.Header.channels(37).bit_volts;
    %ADC6 = contData.Data(38,:);

    % Force MATLAB to empty memory
    contData = [];
end