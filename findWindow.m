function windowCandidatesStartEnd = findWindow(trialData, windowSearchStartTS, windowSearchEndTS, varargin)
    % windowsStartEnd = findWindow(trialData, windowSearchStartTS, windowSearchEndTS);
    % Find window candidates separated by peaks of trialData
    % windowsStartEnd = findWindow(trialData, windowSearchStartTS, windowSearchEndTS,...
    %                              'MinPeakDistance', 50, 'MinPeakHeight', 3);
    %
    % Arguments:
    %   trialData: Trial kinematic data (Mx1) to calculate window candidates using findpeaks
    %               where M is number of points in trial
    %               data could be {'relative_velocity', 'relative_acceleration', 'relative_jerk'}
    %               Default = 'relative_jerk'
    %   windowSearchStartTS: Time sample relative to trial where to start searching for window 
    %               eg. start of trial - 1
    %   windowSearchEndTS: Time sample  relative to trial where to end searching for window
    %               eg. time sample corresponding to 3mm distance in trajectory from start of trial
    %   Additionally, provide necessary findpeaks arguments. See `help fndpeaks`
    %
    % Returns
    %   windowsStartEnd: number of windows x 2 (start, end) matrix of windows candidates
    %                    Example: [start1, end1; start2, end2; ...]

    % Check windowSearchStartTS and windowSearchEndTS values
    if (windowSearchStartTS|windowSearchEndTS) > length(trialData)
        error('findWindow: windowSearch[Start|end]TS > length(trialData). Check windowSearch[Start|end]TS and try again');
        %skip trial
    end
    if (windowSearchStartTS|windowSearchEndTS) <= 0
        error('findWindow: windowSearch[Start|end]TS <= 0. Check (windowSearchStartTS|windowSearchEndTS) and try again');
    end
    if windowSearchStartTS >= windowSearchEndTS
        error('findWindow: windowSearchStartTS >= windowSearchEndTS. Check windowSearch[Start,End]TS and try again');
    end
    if length(find(~(floor([windowSearchStartTS,windowSearchEndTS])==[windowSearchStartTS,windowSearchEndTS])))>=1
        error('findWindow: windowSearch[Start|end]TS is not integer. Check windowSearch[Start,End]TS and try again');
    end
    % Find peaks in trialData from windowSearchStartTS->EndTS
    try
        [pks, pkLocs] = findpeaks(trialData(windowSearchStartTS:windowSearchEndTS), varargin{:});
    catch ME
        windowCandidatesStartEnd = [];
        fprintf('findWindow: %s\n', ME.message)
        return
    end
    if isempty(pkLocs)
        % Init output
        windowCandidatesStartEnd = [];
        return
    end
    % Add windowSearchStartTS to change reference to start of trialData
    pkLocs = pkLocs + windowSearchStartTS - 1;
    % End of window candidate = location of peak
    windowEndTS = pkLocs;
    % Start of window candidate = start or location right after previous window
    windowStartTS = [windowSearchStartTS; windowEndTS(1:end-1)+1];
    % Concatenate windowStart and windowEnd to get window candidates
    windowCandidatesStartEnd = [windowStartTS,windowEndTS];
end