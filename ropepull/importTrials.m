function trialList = importTrials(fpath, filepattern, varargin)
	% trialList = importTrials(fpath);
	% 	Import trials from individual MAT files with trial data from fpath
	% 	Trial data triangulation has been done and contains XYZ data for trial
	% trialList = importTrials(fpath, filepattern)
	% 	Match files that match filepattern (not regex)
	%	trialList = importTrials(fpath, 'CFL*analysis.mat');
	% trialList = importTrials(fpath, filepattern
	%		pose3d,...
	%		'CFL10_03292022_CNO_16_15-51-41',...
	%		'video_fps', 200,...
	%		'dorsoVentralAxis', 'x',...
	%		'peakMarkerName', 'nose', ...
	%		'baseMarkerNames', {'foot_left', 'foot_right'});

	if nargin<2
		filepattern = '*.mat';
	end
	if nargin<1
		fpath = uigetdir(pwd, 'Pick a directory with trial .MAT files with xyz triangulated data');
	end
    
	% Get list of MAT files
	fileList = dir(fullfile(fpath, filepattern));

	% Init triallist output
	trialList = [];

	for f = 1:length(fileList)
		% Init trial output
		trial = struct();
		% Load MAT file with triangulated XYZ data and other metadata
		trial_load = load(fullfile(fileList(f).('folder'),...
						  		   fileList(f).('name')));
		% Loaded trial data should have data for only one trial
		% Loading row=1 to make sure
		trial = getTrialData(...
			trial_load(1).('pose3d'),...
			trial_load(1).('trial'));
	    % Append to trial list
		trialList = cat(1,trialList, trial);
	end
end