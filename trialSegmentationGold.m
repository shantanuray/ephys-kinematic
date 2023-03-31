function trialListGold = trialSegmentationGold(trialListSilver, videoFrames_timestamps, varargin)
    % trialSegmentationGold builds on first pass trial segmentation in trial_segmentation.m. It refines the trial segments:
    %   - Reach start: Instead ofsolely relying on start trigger (eg. tone_on), searches for start of trial
    %     by using jerk peaks and relative velocity (see findReachStart.m)
    %   - Reach end: Instead of solely relying on spout contact, use combination of grip aperture signifying prehension
    %     and relative velocity to mark the retract phase of the reach to identify reach end (see getReachEnd.m)
    % trialListGold = trialSegmentationGold(trialListSilver, videoFrames_timestamps);
    % Arguments:
    %   trialListSilver: struct array with list of trials - see trial_segmentation.m
    %   videoFrames_timestamps: Video time stamps synced to ephys contDataTimestamps. see loadOEbinary_AT.m
    %   'RefBodyPart': Reference body part for fine tuning segmentation
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
    %   'MinPeakDistance', 'minPeakHeight': findpeaks params. Default = nan
    %   'GripApertureDigit1': Choose body part 1 for measuring grip aperture to mark prehension
    %               Default = 'right_d5_knuckle'
    %   'GripApertureDigit2': Choose body part 2 for measuring grip aperture to mark prehension
    %               Default = 'right_d2_knuckle'
    %
    % Returns
    %   trialListGold: struct array with list of trials
    %       - Length of output trial list = input trial list (trialListSilver)
    %       - Trial segment correlation to start trial index remains unchanged (i.e. relation to tone_on/ solenoid_on index remains unchanged)
    %       - Contains segments related to gold start/end and fixed time interval
    %       - Does not contain segments related to spout contact (silver start/end)

    % Initialize inputs
    p = readInput(varargin);

    [refBodyPart,...
        windowStartKinematicVariable, windowStartLimitValue,...
        windowSearchKinematicVariable,...
        windowSelectorVariable, windowSelectorLimitValue,...
        minPeakDistance, minPeakHeight,...
        gripApertureDigit1, gripApertureDigit2] = parseInput(p.Results);

    findPeaksArgins = {};
    if ~isnan(minPeakDistance)
        findPeaksArgins = cat(1, {findPeaksArgins{:}, 'MinPeakDistance', minPeakDistance});
    end
    if ~isnan(minPeakHeight)
        findPeaksArgins = cat(1, {findPeaksArgins{:}, 'MinPeakHeight', minPeakHeight});
    end

    for trialIdx = 1:length(trialListSilver)
        % Get as-is trial data
        trialSilver = trialListSilver(trialIdx);
        % Init output trial data
        % Remove first and last spout contact related fields
        removeFieldPat = {'first_sc','last_sc'};
        removeColPos = findColPos(trialSilver, removeFieldPat);
        removeCols = fieldnames(trialSilver);
        removeCols = removeCols(removeColPos);
        trialGold = rmfield(trialSilver, removeCols);
        if (trialSilver.hitormiss == 1)
            reachStartBestCandidate = findReachStart(trialSilver,...
                'RefBodyPart', refBodyPart,...
                'WindowStartKinematicVariable', windowStartKinematicVariable,...
                'WindowStartLimitValue', windowStartLimitValue,...
                'WindowSearchKinematicVariable', windowSearchKinematicVariable,...
                'WindowSelectorVariable', windowSelectorVariable,...
                'WindowSelectorLimitValue', windowSelectorLimitValue,...
                findPeaksArgins{:});
            if isempty(reachStartBestCandidate)
                fprintf('No peaks found for reach start in trial number %d\n', trialIdx)
                fprintf('Using start of reach = %d\n', 1)
                disp(repmat('-', 1,80))
                %max position is chosen because that represents the velocity minima in the submovement (since velocity is relative to spout @ 000)
                reachStartBestCandidate.maxPos = 1;
            end
            [VelocityMinimafirst_sc_endpoint_idx, VelocityMinimagripAperture_endpoint_idx, first_sc_idx, gripAperture_max_idx] = getReachEnd(trialSilver);
            VelocityMinimagripAperture_endpoint_idx=VelocityMinimagripAperture_endpoint_idx(1);  
            if (~isstruct(reachStartBestCandidate)) | (isnan(VelocityMinimagripAperture_endpoint_idx))
            % TODO: Should check for isnan but isnan errors on struct
                fprintf('Reach did not cross required limit in fixed reach interval %d\n', trialIdx)
                fprintf('Skipping trial\n')
                trialGold.('reach_start_idx') = nan;
                trialGold.('reach_start_ts') = nan;
                trialGold.('reach_end_idx') = nan;
                trialGold.('reach_end_ts') = nan;
                trialGold.('grasp_start_idx') = nan;
                trialGold.('grasp_start_ts') = nan;
                trialGold.('grasp_end_idx') = nan;
                trialGold.('grasp_end_ts') = nan;
                trialGold.('aniposeData_reach') = nan;
                trialGold.('aniposeData_grasp') = nan;
                trialGold.('aniposeData_reach_relative') = nan;
                trialGold.('aniposeData_grasp_relative') = nan;
                emgColPos = findColPos(trialGold, 'EMG_');
                emgCols = fieldnames(trialGold);
                emgCols = emgCols(emgColPos);
                for emgColIdx = 1:length(emgCols)
                    emgCol = emgCols{emgColIdx};
                    trialGold.(strcat(emgCol(1:strfind(emgCol,'_fixed')-1), '_reach')) = nan;
                    trialGold.(strcat(emgCol(1:strfind(emgCol,'_fixed')-1), '_grasp')) = nan;
                end
                disp(repmat('-', 1,80))
            else
                reach_start_idx = reachStartBestCandidate.maxPos;
                reach_end_idx = VelocityMinimagripAperture_endpoint_idx;
               [grasp_start_idx, grasp_end_idx] = getGrasp(trialSilver, VelocityMinimagripAperture_endpoint_idx);

                %% takes all the EMG data between each start and end index
                %% start_ts is in terms of videoFrames_timestamps
                %% start_idx is the index into videoFrames_timestamps
                %% reach/grasp_start/end_idx is wrt start_idx
                reach_start_ts = videoFrames_timestamps(trialSilver.start_idx+reach_start_idx-1)-trialSilver.start_ts+1;
                reach_end_ts = videoFrames_timestamps(trialSilver.start_idx+reach_end_idx-1)-trialSilver.start_ts+1;
                grasp_start_ts = videoFrames_timestamps(trialSilver.start_idx+grasp_start_idx-1)-trialSilver.start_ts+1;
                grasp_end_ts = videoFrames_timestamps(trialSilver.start_idx+grasp_end_idx-1)-trialSilver.start_ts+1;
                trialGold.('reach_start_idx') = reach_start_idx;
                trialGold.('reach_start_ts') = reach_start_ts;
                trialGold.('reach_end_idx') = reach_end_idx;
                trialGold.('reach_end_ts') = reach_end_ts;
                trialGold.('grasp_start_idx') = grasp_start_idx;
                trialGold.('grasp_start_ts') = grasp_start_ts;
                trialGold.('grasp_end_idx') = grasp_end_idx;
                trialGold.('grasp_end_ts') = grasp_end_ts;
                trialGold.('aniposeData_reach') = trialSilver.('aniposeData_fixed')(reach_start_idx:reach_end_idx, :);
                trialGold.('aniposeData_grasp') = trialSilver.('aniposeData_fixed')(grasp_start_idx:grasp_end_idx, :);
                trialGold.('aniposeData_reach_relative') = trialSilver.('aniposeData_fixed_relative')(reach_start_idx:reach_end_idx, :);
                trialGold.('aniposeData_grasp_relative') = trialSilver.('aniposeData_fixed_relative')(grasp_start_idx:grasp_end_idx, :);
                emgColPos = findColPos(trialGold, 'EMG_');
                emgCols = fieldnames(trialGold);
                emgCols = emgCols(emgColPos);
                for emgColIdx = 1:length(emgCols)
                    emgCol = emgCols{emgColIdx};
                    trialGold.(strcat(emgCol(1:strfind(emgCol,'_fixed')-1), '_reach')) = trialGold.(emgCol)(reach_start_ts:reach_end_ts);
                    trialGold.(strcat(emgCol(1:strfind(emgCol,'_fixed')-1), '_grasp')) = trialGold.(emgCol)(grasp_start_ts:grasp_end_ts);
                end
            end
        else
            fprintf('Miss trial. Trial number %d\n', trialIdx)
            fprintf('Skipping trial\n')
            trialGold.('reach_start_idx') = nan;
            trialGold.('reach_start_ts') = nan;
            trialGold.('reach_end_idx') = nan;
            trialGold.('reach_end_ts') = nan;
            trialGold.('grasp_start_idx') = nan;
            trialGold.('grasp_start_ts') = nan;
            trialGold.('grasp_end_idx') = nan;
            trialGold.('grasp_end_ts') = nan;
            trialGold.('aniposeData_reach') = nan;
            trialGold.('aniposeData_grasp') = nan;
            trialGold.('aniposeData_reach_relative') = nan;
            trialGold.('aniposeData_grasp_relative') = nan;
            emgColPos = findColPos(trialGold, 'EMG_');
            emgCols = fieldnames(trialGold);
            emgCols = emgCols(emgColPos);
            for emgColIdx = 1:length(emgCols)
                emgCol = emgCols{emgColIdx};
                trialGold.(strcat(emgCol(1:strfind(emgCol,'_fixed')-1), '_reach')) = nan;
                trialGold.(strcat(emgCol(1:strfind(emgCol,'_fixed')-1), '_grasp')) = nan;
            end
            disp(repmat('-', 1,80))
        end
        fn = fieldnames(trialGold);
        for f =1:length(fn)
            trialListGold(trialIdx).(fn{f}) = trialGold.(fn{f});
        end
    end

    %% Read input
    function p = readInput(input)
        p = inputParser;
        addParameter(p, 'RefBodyPart', 'right_d3_knuckle_r', @isstr);
        addParameter(p, 'WindowStartKinematicVariable', 'aniposeData_fixed_relative', @isstr);
        addParameter(p, 'WindowStartLimitValue',10, @isfloat);
        addParameter(p, 'WindowSearchKinematicVariable', 'aniposeData_fixed_relative_jerk', @isstr);
        addParameter(p, 'WindowSelectorVariable', 'aniposeData_fixed_relative_velocity', @isstr);
        addParameter(p, 'MinPeakDistance', nan, @isfloat);
        addParameter(p, 'MinPeakHeight', nan, @isfloat);
        addParameter(p, 'WindowSelectorLimitValue',4,@isfloat); 
        addParameter(p, 'GripApertureDigit1', 'right_d5_knuckle', @isstr);
        addParameter(p, 'GripApertureDigit2', 'right_d2_knuckle', @isstr);
        parse(p, input{:});
    end

    function [refBodyPart,...
        windowStartKinematicVariable, windowStartLimitValue,...
        windowSearchKinematicVariable,...
        windowSelectorVariable, windowSelectorLimitValue,...
        minPeakDistance, minPeakHeight,...
        gripApertureDigit1, gripApertureDigit2] = parseInput(p)
        refBodyPart = p.RefBodyPart;
        windowStartKinematicVariable = p.WindowStartKinematicVariable;
        windowStartLimitValue = p.WindowStartLimitValue;
        windowSearchKinematicVariable = p.WindowSearchKinematicVariable;
        windowSelectorVariable = p.WindowSelectorVariable;
        windowSelectorLimitValue = p.WindowSelectorLimitValue;
        minPeakDistance = p.MinPeakDistance;
        minPeakHeight = p.MinPeakHeight;
        gripApertureDigit1 = p.GripApertureDigit1;
        gripApertureDigit2 = p.GripApertureDigit2;
    end
end 