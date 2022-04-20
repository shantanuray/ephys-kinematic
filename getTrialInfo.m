function trial = getTrialInfo(aniposeData,...
							  EMG_biceps,...
							  EMG_triceps,...
							  EMG_ecu,...
							  EMG_trap,...
  							  aniposeNumTS, ephysNumTS,...
  							  contDataTimestamps,...
							  lightOnTrig_ts,...
  							  hitormiss,...
  							  perchOnStart,...
							  start_ts, start_idx,...
							  end_ts_first, end_idx_first,...
							  end_ts_last, end_idx_last)

	trial.('hitormiss') = hitormiss;
	trial.('perchOnStart') = perchOnStart;
	if ~isnan(start_ts)
		trial.('start_ts') = start_ts;
		trial.('start_idx') = start_idx;
		% aniposeData and videoFrames_timestamps have the same # of total samples and are aligned with each other
		% start_idx is the index into videoFrames_timestamps and hence that can be used directly for aniposeData
		% i.e. index into videoFrames_timestamps is same as index into aniposedata
		trial.('aniposeData_fixed') = aniposeData(start_idx:min(size(aniposeData, 1), start_idx+aniposeNumTS-1), :);
		% ephys data and contData timestamps have the same # of samples and are aligned with each other
		% Find index into contDataTimestamps using videoFrames_timestamps value, i.e. start_ts
		ephys_start_idx = find(contDataTimestamps == start_ts);
		ephys_end_idx_fixed = ephys_start_idx+ephysNumTS-1;
		% Use this index into contDataTimestamps to reference data from EMG channels
		trial.('EMG_biceps_fixed') = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_fixed))';
		trial.('EMG_triceps_fixed') = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_fixed))';
		trial.('EMG_ecu_fixed') = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_fixed))';
		trial.('EMG_trap_fixed') = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_fixed))';
		% lightOnTrig_ts is a subset of contDataTimestamps
		% and start_ts is from videoFrames_timestamps, which is a subset of contDataTimestamps
		% Hence lightOnTrig_ts value is comparable to start_ts (do not use index)
		trial.('lightOnTrig_ts_fixed') = intersect(start_ts:start_ts+ephysNumTS-1, lightOnTrig_ts);
		if isempty(trial.('lightOnTrig_ts_fixed'))
			trial.('lightTrig_fixed') = 'OFF';
		else
			trial.('lightTrig_fixed') = 'ON';
		end
		if ~isnan(end_ts_first) & (hitormiss==1)
			% comment
			trial.('lightOnTrig_ts') = intersect(start_ts:end_ts_first, lightOnTrig_ts);
			if isempty(trial.('lightOnTrig_ts'))
				trial.('lightTrig') = 'OFF';
			else
				trial.('lightTrig') = 'ON';
			end
			trial.('end_ts_first') = end_ts_first;
			trial.('end_ts_last') = end_ts_last;
			trial.('end_idx_first') = end_idx_first;
			trial.('end_idx_last') = end_idx_last;
			% takes all the anipose data between each start and end index
			% Assumption: ephysNumTS is the same for index as well as time samples for fixed interval
			if end_idx_first<size(aniposeData, 1)
				trial.('aniposeData_first_sc') = aniposeData(start_idx:end_idx_first, :);
				trial.('aniposeData_last_sc') = aniposeData(start_idx:end_idx_last, :);
				
			else
				trial.('aniposeData_first_sc') = [];
				trial.('aniposeData_last_sc') = [];
			end
			% takes all the EMG data between each start and end index
			ephys_end_idx_first_sc = find(contDataTimestamps == end_ts_first);
			ephys_end_idx_last_sc = find(contDataTimestamps == end_ts_last);
			trial.('EMG_biceps_first_sc') = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_first_sc))';
			trial.('EMG_triceps_first_sc') = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_first_sc))';
			trial.('EMG_ecu_first_sc') = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_first_sc))';
			trial.('EMG_trap_first_sc') = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_first_sc))';
			trial.('EMG_biceps_last_sc') = EMG_biceps(:, ephys_start_idx:min(size(EMG_biceps, 2), ephys_end_idx_last_sc))';
			trial.('EMG_triceps_last_sc') = EMG_triceps(:, ephys_start_idx:min(size(EMG_triceps, 2), ephys_end_idx_last_sc))';
			trial.('EMG_ecu_last_sc') = EMG_ecu(:, ephys_start_idx:min(size(EMG_ecu, 2), ephys_end_idx_last_sc))';
			trial.('EMG_trap_last_sc') = EMG_trap(:, ephys_start_idx:min(size(EMG_trap, 2), ephys_end_idx_last_sc))';
		else
			% trial.('lightOnTrig_ts') = trial.lightOnTrig_ts_fixed;
			% trial.('lightTrig') = trial.lightTrig_fixed;
			trial.('aniposeData_first_sc') = [];
			trial.('aniposeData_last_sc') = [];
			trial.('EMG_biceps_first_sc') = [];
			trial.('EMG_triceps_first_sc') = [];
			trial.('EMG_ecu_first_sc') = [];
			trial.('EMG_trap_first_sc') = [];
			trial.('EMG_biceps_last_sc') = [];
			trial.('EMG_triceps_last_sc') = [];
			trial.('EMG_ecu_last_sc') = [];
			trial.('EMG_trap_last_sc') = [];
		end
	end
end