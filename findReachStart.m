function windowCandidate = findReachStart(trial, varargin)
    % windowCandidate = findReachStart(trial,...
    %                 'RefBodyPart', refBodyPart,...
    %                 'WindowStartKinematicVariable', windowStartKinematicVariable,...
    %                 'WindowStartLimitValue', windowStartLimitValue,...
    %                 'WindowSearchKinematicVariable', windowSearchKinematicVariable,...
    %                 'WindowSelectorKinematicVariable', windowSelectorKinematicVariable,...
    %                 'WindowSelectorLimitValue', windowSelectorLimitValue,...
    %                 'MinPeakDistance', 50, 'MinPeakHeight', 3);
    % Reach trials are triggered using events such as tone_on. In addition, other events such as solemoid_on provide motivation to the subject to start the reaching movement. However, the subject often does not immediately start the reaching movement after these events. This function will identify the start of the start of reach segment using kinematic variables. Process:
    % - Identify segment of trial that could be included in reach start (such as max relative distance of refBodyPart from tone_on)
    % - Use peaks of relative_jerk (or similar) to identify windows where the reach could have started
    % - Use relative_velocity (or similar) >= known value to identify which window correlates to viable candidate for reach start; from these candidates choose the latest as the best candidate
    %
    % windowCandidate = findReachStart(trialData,...
    %                 'RefBodyPart', 'right_d3_knuckle_r',...
    %                 'WindowStartKinematicVariable', 'relative_distance',...
    %                 'WindowStartLimitValue','3',...
    %                 'WindowSearchKinematicVariable','relative_jerk',...
    %                 'WindowSelectorVariable', 'relative_velocity',...
    %                 'WindowSelectorLimitValue', 5,...
    %                 'MinPeakDistance', 50, 'MinPeakHeight', 3);
    %
    % Arguments:
    %   trial: struct() with kinematic data for a single trial
    %   'RefBodyPart': Reference body part for retieving kinematic data
    %               Default = 'right_d3_knuckle_r'
    %   'WindowStartKinematicVariable': Function used to determine which window to choose
    %               Default = 'aniposeData_fixed_relative'
    %   'WindowStartLimitValue': Value of WindowStartKinematicVariable (in mm)
    %   'WindowSearchKinematicVariable': Function used to determine which window to choose
    %               Default = 'aniposeData_fixed_relative_jerk'
    %   'WindowSelectorVariable': Function used to determine which window to choose
    %               Default = 'aniposeData_fixed_relative_velocity'
    %   'WindowSelectorLimitValue': Choose candidates with WindowSelectorVariable value >= WindowSelectorLimitValue
    %               Default = 5mm/s
    %   findpeak parameters:
    %   'MinPeakDistance', 'MinPeakHeight'
    %
    % Returns
    %   windowCandidate: struct(), Time sample information of the section of the trial indicating the start
    %       .startPos
    %       .endPos
    %       .maxPos
    
    % Initialize inputs
    p = readInput(varargin);

    [refBodyPart,...
        windowStartKinematicVariable, windowStartLimitValue,...
        windowSearchKinematicVariable,...
        windowSelectorVariable, windowSelectorLimitValue,...
        minPeakDistance, minPeakHeight] = parseInput(p.Results);
    findPeaksArgins = {};
    if ~isnan(minPeakDistance)
        findPeaksArgins = cat(1, {findPeaksArgins{:}, 'MinPeakDistance', minPeakDistance});
    end
    if ~isnan(minPeakHeight)
        findPeaksArgins = cat(1, {findPeaksArgins{:}, 'MinPeakHeight', minPeakHeight});
    end

    % Init output
    windowCandidate = [];
 
    % 1. Identify section of trial that could be included in reach start analysis
    %    Example: 3mm of trial trajectory from the start (tone_on)
    % Init trialData to be used for start of window analysis
    trialData_windowStart = trial.(windowStartKinematicVariable).(refBodyPart);
    % Init trialData to be used for window candidate analysis
    trialData_windowCandidates = trial.(windowSearchKinematicVariable).(refBodyPart);
    % Init limit of reach start
    trialData_startMaxPos = nan;
    if  strcmpi(windowStartKinematicVariable, 'none')
        % If none, use entire available data
       trialData_startMaxPos = height(trialData_windowCandidates);
    else
        % Assumptions:
        % - windowStartKinematicVariable is a relative measurement wrt to a fixed point such as spout
        % - WindowStartLimitValue has been provided wrt to first point
        % Find diff to get relative measurement to first point
        % Relative measurements are wrt spout and hence first point is the furthest away
        trialData_startmax = trialData_windowStart(1) - trialData_windowStart;
        trialData_startMaxPos = find(trialData_startmax>=windowStartLimitValue);
        % Please note that if windowStartLimitValue is not reached then trialData_startMaxPos = []
        if length(trialData_startMaxPos) >=1
            % If trial length > required reach limit (eg. 3 mm), then it is a valid trial
            trialData_startMaxPos = trialData_startMaxPos(1);
        else
            trialData_startMaxPos = nan;
        end
    end
    % 2. Use peaks of windowSearchKinematicVariable to identify windows where the reach could have started
    % TODO: Find findpeaks optimal params
    if isnan(trialData_startMaxPos)
        % reach did not cross the required reach limit (eg. 3 mm), then it is not a valid trial
        % return nan for window candidate
        fprintf('findReachStart: Reach did not cross reach limit of %0.2f\nReturning windowCandidate=nan\n', windowStartLimitValue)
        windowCandidate = nan;
        return;
    end
    windowCandidates = findWindow(trialData_windowCandidates, 1, trialData_startMaxPos,...
                                  findPeaksArgins{:});
    if isempty(windowCandidates)
        % If reach crossed the required reach limit (eg. 3 mm), but we were unable to find jerk peak
        % return empty for window candidate
        fprintf('findReachStart: Unable to find window candidates for %s; start pos = %d\nReturning windowCandidate=[]\n', windowSearchKinematicVariable, trialData_startMaxPos)
        windowCandidate = [];
        return;
    end

    % 3. Use max of windowSelectorVariable to identify which window correlates to the best candidate for reach start
    % Init trialData to be used for window candidate selection
    trialData_windowSelection = trial.(windowSelectorVariable).(refBodyPart)(1:trialData_startMaxPos);
    % TODO: Optimize by replacing loop with one of the `fun` functions
    % Init loop temp variables
    windowCandidateNum = 0;
    trialData_window_max = repmat(-Inf, height(windowCandidates), 1);
    for num_candidate = 1:height(windowCandidates)
        % Find max within windows
        trialData_window_max(num_candidate) = max(trialData_windowSelection(windowCandidates(num_candidate, 1):windowCandidates(num_candidate, 2)));
    end
    % Find which window have max <= windowSelectorLimitValue, < because velocity towards spout will be negative 
    windowCandidateNum = find(abs(trialData_window_max)>=windowSelectorLimitValue);
    % If multiple candidates, choose the latest candidate
    if length(windowCandidateNum) >= 1
        windowCandidateNum = windowCandidateNum(end);
    end
    if isempty(windowCandidateNum)
        fprintf('findReachStart: Unable to find window with %s > %0.1f', windowSelectorVariable, windowSelectorLimitValue)
        windowCandidate = [];
        return;
    end
    % Init output to the best candidate
    windowCandidate.startPos = windowCandidates(windowCandidateNum, 1);
    windowCandidate.endPos = windowCandidates(windowCandidateNum, 2);
    trialData_windowSelected = trialData_windowSelection(windowCandidate.startPos:windowCandidate.endPos);
    windowCandidate.maxPos = windowCandidate.startPos + find(trialData_windowSelected == max(trialData_windowSelected)) - 1;
    windowCandidate.minPos = windowCandidate.startPos + find(trialData_windowSelected == min(trialData_windowSelected)) - 1;
    
    %% Read input
    function p = readInput(input)
        p = inputParser;
        addParameter(p, 'RefBodyPart', 'right_d3_knuckle_r', @isstr);
        addParameter(p, 'WindowStartKinematicVariable', 'aniposeData_fixed_relative', @isstr);
        addParameter(p, 'WindowStartLimitValue', 10, @isfloat);
        addParameter(p, 'WindowSearchKinematicVariable', 'aniposeData_fixed_relative_jerk', @isstr);
        addParameter(p, 'WindowSelectorVariable', 'aniposeData_fixed_relative_velocity', @isstr);
        addParameter(p, 'MinPeakDistance', nan, @isfloat);
        addParameter(p, 'MinPeakHeight', nan, @isfloat);
        addParameter(p, 'WindowSelectorLimitValue',4,@isfloat); 
        parse(p, input{:});
    end

    function [refBodyPart,...
        windowStartKinematicVariable, windowStartLimitValue,...
        windowSearchKinematicVariable,...
        windowSelectorVariable, windowSelectorLimitValue,...
        minPeakDistance, minPeakHeight] = parseInput(p)
        refBodyPart = p.RefBodyPart;
        windowStartKinematicVariable = p.WindowStartKinematicVariable;
        windowStartLimitValue = p.WindowStartLimitValue;
        windowSearchKinematicVariable = p.WindowSearchKinematicVariable;
        windowSelectorVariable = p.WindowSelectorVariable;
        windowSelectorLimitValue = p.WindowSelectorLimitValue;
        minPeakDistance = p.MinPeakDistance;
        minPeakHeight = p.MinPeakHeight;

    end
end