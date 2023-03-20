function emgChannelDataOut = getTrialEMGChannelData(...
	emgChannelData,...
	channelLabel,...
	ephysInfo,...
	trialReachInfo,...
	fixedReachIntervalms)
	
	ephysNumTS = round((fixedReachIntervalms/1000)*ephysInfo.ephysSamplingRate,0);
	% Init output
	emgChannelDataOut.(join([string(channelLabel), "fixed"], "_")) = [];
	emgChannelDataOut.(join([string(channelLabel), "first_sc"], "_")) = [];
	emgChannelDataOut.(join([string(channelLabel), "last_sc"], "_")) = [];

	if ~isnan(trialReachInfo.start_ts)
		% ephys data and contData timestamps have the same # of samples and are aligned with each other
		% Find index into ephysInfo.contDataTimestamps using videoFrames_timestamps value, i.e. trialReachInfo.start_ts
		ephys_start_idx = find(ephysInfo.contDataTimestamps == trialReachInfo.start_ts);
		ephys_end_idx_fixed = ephys_start_idx+ephysNumTS-1;
		% Use this index into ephysInfo.contDataTimestamps to reference data from EMG channels
		% Note: MATLAB differentiates between '' and ""; 
		%	'' is a character; ['a','b'] is a character array and ['a','b'] == 'ab'
		%	"" is a string; ['a','b'] is a string and ["a", "b"] ~= "ab"
		%   `join` assumes a string operation and hence the conversion to string
		%   `contains` assumes that the pattern is a character array and hence should include conversion to char. not used here - just as reference
		emgChannelDataOut.(join([string(channelLabel), "fixed"], "_")) = emgChannelData(:, ephys_start_idx:min(size(emgChannelData, 2), ephys_end_idx_fixed))';
		if ~isnan(trialReachInfo.end_ts_first) & (trialReachInfo.hitormiss==1)
			% takes all the EMG data between each start and end index
			ephys_end_idx_first_sc = find(ephysInfo.contDataTimestamps == trialReachInfo.end_ts_first);
			ephys_end_idx_last_sc = find(ephysInfo.contDataTimestamps == trialReachInfo.end_ts_last);
			emgChannelDataOut.(join([string(channelLabel), "first_sc"], "_")) = emgChannelData(:, ephys_start_idx:min(size(emgChannelData, 2), ephys_end_idx_first_sc))';
			emgChannelDataOut.(join([string(channelLabel), "last_sc"], "_")) = emgChannelData(:, ephys_start_idx:min(size(emgChannelData, 2), ephys_end_idx_last_sc))';
		end
	end
end