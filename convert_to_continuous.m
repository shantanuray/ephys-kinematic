function cont_array = convert_to_continuous(on_array, off_array, nSamples)
    % cont_array = convert_to_continuous(on_array, off_array, nSamples);
    % Converts a pulse on - off set of arrays to a square wave that is on from
    % when the measurement is on till the next off
    % Outputs:
    % * cont_array: (1,nSamples) array of 1s when measurement is on till next off and 0 otherwise
    % Inputs:
    % * on_array: when measurement is on
    % * off_array: when measurement is off
    % * nSamples: # of total samples in ephys data
    %
    % Example: solenoid_cont = convert_to_continuous(solenoid_on, solenoid_off, 9931520);

    % init to zeros (off)
    cont_array = zeros(1,nSamples);
    % set value to 1 when on array comes on till just before it turns off
    % assumption: on and off array are same length and in correct order
    % also, on and off array have time samples and hence starting point is 0
    on_array = sort(on_array);
    off_array = sort(off_array);
    for i = 1:min(length(on_array), length(off_array))
        cont_array(on_array(i)+1:off_array(i)) = 1; % Adding 1 to compensate for starting point = 0
    end
end