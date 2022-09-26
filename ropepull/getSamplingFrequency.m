function fs = getSamplingFrequency(trial, fs_name)
	% fs = getSamplingFrequency(trial, 'video_fps');
	% Get sampling frequency from trial
	% fs = getSamplingFrequency(trial, fs_name);
	%	Default fs_name: str = 'video_fps' % Kinematoc

	if nargin < 2
		fs_name = 'video_fps';
	end
	assert(find(contains(fieldnames(trial), fs_name)), sprintf('%s missing', fs_name));
	fs = trial.(fs_name);
