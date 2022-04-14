function trial = getTrialInfo(aniposeData,...
							  EMG_biceps,...
							  EMG_triceps,...
							  EMG_ecu,...
							  EMG_trap,...
							  startEvent,...
  							  aniposeNumTS, ephysNumTS,...
  							  contDataTimestamps,...
							  lightOnTrig_ts,...
  							  hitormiss,...
  							  perchOnStart,...
							  start_ts, start_idx,...
							  end_ts_first, end_idx_first,...
							  end_ts_last, end_idx_last)

	if length(startEvent)>0
		startEvent = strcat('_', startEvent);
	end
	trial.(strcat('hitormiss', startEvent)) = hitormiss;
	trial.(strcat('perchOnStart', startEvent)) = perchOnStart;
	if ~isnan(start_ts)
		trial.(strcat('start_ts', startEvent)) = start_ts;
		trial.(strcat('start_idx', startEvent)) = start_idx;
		% aniposeData and videoFrames_timestamps have the same # of total samples and are aligned with each other
		% start_idx is the index into videoFrames_timestamps and hence that can be used directly for aniposeData
		% i.e. index into videoFrames_timestamps is same as index into aniposedata
		trial.(strcat('aniposeData_fixed', startEvent)) = aniposeData(start_idx:min(size(aniposeData, 1), start_idx+aniposeNumTS-1), :);
		% ephys data and contData timestamps have the same # of samples and are aligned with each other
		% Find index into contDataTimestamps using videoFrames_timestamps value, i.e. start_ts
		ephys_start_idx = find(contDataTimestamps == start_ts);
		ephys_end_idx_fixed = ephys_start_idx+ephysNumTS-1;
		% Use this index into contDataTimestamps to reference data from EMG channels
		trial.(strcat('EMG_biceps_fixed', startEvent)) = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_fixed))';
		trial.(strcat('EMG_triceps_fixed', startEvent)) = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_fixed))';
		trial.(strcat('EMG_ecu_fixed', startEvent)) = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_fixed))';
		trial.(strcat('EMG_trap_fixed', startEvent)) = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_fixed))';
		% lightOnTrig_ts is a subset of contDataTimestamps
		% and start_ts is from videoFrames_timestamps, which is a subset of contDataTimestamps
		% Hence lightOnTrig_ts value is comparable to start_ts (do not use index)
		trial.(strcat('lightOnTrig_ts_fixed', startEvent)) = intersect(start_ts:start_ts+ephysNumTS-1, lightOnTrig_ts);
		if isempty(trial.(strcat('lightOnTrig_ts_fixed', startEvent)))
			trial.(strcat('lightTrig_fixed', startEvent)) = 'OFF';
		else
			trial.(strcat('lightTrig_fixed', startEvent)) = 'ON';
		end
		if ~isnan(end_ts_first) & (hitormiss==1)
			% comment
			trial.(strcat('lightOnTrig_ts', startEvent)) = intersect(start_ts:end_ts_first, lightOnTrig_ts);
			if isempty(trial.(strcat('lightOnTrig_ts', startEvent)))
				trial.(strcat('lightTrig', startEvent)) = 'OFF';
			else
				trial.(strcat('lightTrig', startEvent)) = 'ON';
			end
			trial.(strcat('end_ts_first', startEvent)) = end_ts_first;
			trial.(strcat('end_ts_last', startEvent)) = end_ts_last;
			trial.(strcat('end_idx_first', startEvent)) = end_idx_first;
			trial.(strcat('end_idx_last', startEvent)) = end_idx_last;
			% takes all the anipose data between each start and end index
			% Assumption: ephysNumTS is the same for index as well as time samples for fixed interval
			if end_idx_first<size(aniposeData, 1)
				trial.(strcat('aniposeData_first_sc', startEvent)) = aniposeData(start_idx:end_idx_first, :);
				trial.(strcat('aniposeData_last_sc', startEvent)) = aniposeData(start_idx:end_idx_last, :);
				
			else
				trial.(strcat('aniposeData_first_sc', startEvent)) = [];
				trial.(strcat('aniposeData_last_sc', startEvent)) = [];
			end
			% takes all the EMG data between each start and end index
			ephys_end_idx_first_sc = find(contDataTimestamps == end_ts_first);
			ephys_end_idx_last_sc = find(contDataTimestamps == end_ts_last);
			trial.(strcat('EMG_biceps_first_sc', startEvent)) = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_first_sc))';
			trial.(strcat('EMG_triceps_first_sc', startEvent)) = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_first_sc))';
			trial.(strcat('EMG_ecu_first_sc', startEvent)) = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_first_sc))';
			trial.(strcat('EMG_trap_first_sc', startEvent)) = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_first_sc))';
			trial.(strcat('EMG_biceps_last_sc', startEvent)) = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_last_sc))';
			trial.(strcat('EMG_triceps_last_sc', startEvent)) = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_last_sc))';
			trial.(strcat('EMG_ecu_last_sc', startEvent)) = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_last_sc))';
			trial.(strcat('EMG_trap_last_sc', startEvent)) = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_last_sc))';
		else
			trial.(strcat('lightOnTrig_ts', startEvent)) = trial.lightOnTrig_ts_fixed;
			trial.(strcat('lightTrig', startEvent)) = trial.lightTrig_fixed;
			trial.(strcat('aniposeData_first_sc', startEvent)) = [];
			trial.(strcat('aniposeData_last_sc', startEvent)) = [];
			trial.(strcat('EMG_biceps_first_sc', startEvent)) = [];
			trial.(strcat('EMG_triceps_first_sc', startEvent)) = [];
			trial.(strcat('EMG_ecu_first_sc', startEvent)) = [];
			trial.(strcat('EMG_trap_first_sc', startEvent)) = [];
			trial.(strcat('EMG_biceps_last_sc', startEvent)) = [];
			trial.(strcat('EMG_triceps_last_sc', startEvent)) = [];
			trial.(strcat('EMG_ecu_last_sc', startEvent)) = [];
			trial.(strcat('EMG_trap_last_sc', startEvent)) = [];
		end
	end
end