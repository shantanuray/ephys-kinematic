function emg_filtered = emgFilter(emg_signal, fs, varargin)
	% Initialize inputs
    p = readInput(varargin);
    [bandpass_freq, rectify_flag, low_pass_freq] = parseInput(p.Results);

    % Bandpass filter
	emg_filtered = bandpass(emg_signal, bandpass_freq, fs);
	% Rectify
	if rectify_flag
		emg_filtered = abs(emg_filtered);
	end
	% Low pass filter
	emg_filtered = lowpass(emg_filtered, low_pass_freq, fs);


	%% Read input
    function p = readInput(input)
        %   - bandpass_freq     Default - [300, 1000]
        %   - rectify_flag      Default - true
        %   - low_pass_freq     Default - 50
        p = inputParser;
        bandpass_freq = [300, 1000];
        rectify_flag = true;
        low_pass_freq = 50;

        addParameter(p,'bandpass_freq',bandpass_freq, @isnumeric);
        addParameter(p,'rectify_flag',rectify_flag, @islogical);
        addParameter(p,'low_pass_freq',low_pass_freq, @isnumeric);
        parse(p, input{:});
    end

    function [bandpass_freq, rectify_flag, low_pass_freq] = parseInput(p)
        bandpass_freq = p.bandpass_freq;
        rectify_flag = p.rectify_flag;
        low_pass_freq = p.low_pass_freq;;
    end

end