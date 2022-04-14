function cont_array = convert_to_continuous(on_array, off_array, contDataTimeStamps, nSamples)
    % cont_array = convert_to_continuous(on_array, off_array, nSamples);
    % Converts a pulse on - off set of arrays to a square wave that is on from
    % when the measurement is on till the next off
    % Outputs:
    % * cont_array: (1,nSamples) array of 1s when measurement is on till next off and 0 otherwise
    % Inputs:
    % * on_array: event timestamps when measurement is on
    % * off_array: event timestamps when measurement is off
    % * contDataTimeStamps: reference event timestamps 
    % * nSamples: # of total samples in ephys data
    %
    % Example: solenoid_cont = convert_to_continuous(solenoid_on, solenoid_off, eventData.Timestamps, 9931520);

    % Assumptions:
    % nSamples is with reference to length of contData
    % on/off array is with reference to eventData
    % Hence, nSamples >= length(eventData.Timestamps)
    % eventData is a subset of contData
    % contData and eventData.Timestamps may not start from 1

    % init to zeros (no data)
    cont_array = zeros(1,nSamples);
    % set value to 1 when on array comes on till just before it turns off
    % assumption: on and off array are same length and in correct order
    % also, on and off array have time samples and hence starting point is 0
    on_array = sort(on_array);
    off_array = sort(off_array);
    for i = 1:min(length(on_array), length(off_array))
        on_idx = find(on_array(i)==contDataTimeStamps);
        next_off = find(off_array>on_array(i));
        if ~isempty(next_off)
            off_idx = find(off_array(next_off(1))==contDataTimeStamps);
            cont_array(on_idx:off_idx) = 1;
        end
    end
end