function eventData = getEventDataFromEphys(oebin_file)
    % Get eventData from ephys recording.
    %
    % emgData = getEMGDatafromEphys(oebin_file, maxSamples);
    %
    % Processes oebin_file and extracts event data
    % 
    % Inputs:
    %   - oebin_file
    % Output:
    %   - emgData: struct()
    %	  - tone_on
    %	  - tone_off
    %	  - solenoid_on
    %	  - solenoid_off
    %	  - perchContact_on
    %	  - perchContact_off
    %	  - spoutContact_on
    %	  - spoutContact_off
    %	  - lightOnTrig_ts

    % Note: Passing oebin_file instead of raw data (esp. contData) because MTALB seems to be passing by value and then not releasing memory
    % Loading it within the functon seems to be optimizing the memory consumption for raw data
    % contData has recordings for entire time period over several channels and floating point data, hence is quite large

    %% Load using Open Ephys functions
    eventData_raw = load_open_ephys_binary(oebin_file, 'eventData', 1);
    contData_raw = load_open_ephys_binary(oebin_file, 'continuous', 1);
    %% Fetch and rename digital input eventData
    eventData.tone_on = eventData.Timestamps(eventData.Data == 2);
    eventData.tone_off = eventData.Timestamps(eventData.Data == -2);
    eventData.solenoid_on = eventData.Timestamps(eventData.Data == 4);
    eventData.solenoid_off = eventData.Timestamps(eventData.Data == -4);
    eventData.perchContact_on = eventData.Timestamps(eventData.Data == 6);
    eventData.perchContact_off = eventData.Timestamps(eventData.Data == -6);
    eventData.spoutContact_on = eventData.Timestamps(eventData.Data == 8);
    eventData.spoutContact_off = eventData.Timestamps(eventData.Data == -8);
    laserTrig = contData.Data(40,:).*contData.Header.channels(40).bit_volts;
    eventData.lightOnTrig_ts=contData.Timestamps(find(laserTrig>3.3));

    % Force MATLAB to empty memory
    eventData_raw = [];
    contData_raw = [];
end