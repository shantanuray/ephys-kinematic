function summaryTable = getSummaryInfo(trial_list, fs, outputLabel, bodyPart, dataLabel, trialIndex)
	% summaryTable = getSummaryInfo(trial_list, fs, outputLabel, bodyPart, dataLabel, trialIndex)
	% Create summary table for set of trials of given experiment
	% Input:
	%   - trial_list: list of segmented trials with reach data and velicoty, speed information
	%	- fs:  (float) Sampling frequency
	%	- outputLabel: (str) Label for the entire experiment
	%   - bodyPart: (str) body part label (Default) {'right_d2_knuckle'}
	%	- dataLabel: (str) Data table to use for computation (Default: 'aniposeData_first_sc')
	%				Values can be:
	%					* 'aniposeData_first_sc'
	%					* 'aniposeData_fixed'
	%					* 'aniposeData_last_sc'
	%	- trialIndex: (int array) index of trials to include in summary (Default: 1:length(trial_list))
	% Output:
	%	- summaryTable: Table with following columns:
	%		* label (string) = outputLabel
	%		* trialIndex (integer)
	%		* hitormiss = 0/1 (if mouse reached target)
	%		* lightTrig	= ("ON" or "OFF")
	%		* x,y,zDist = total distance travel along the x,y,z axis resp
	%		* xyzDist = Total distance traveled
	%		* xyzSpeed = Average speed
	%		* x,y,zSpeed = Average speed along the x,y,z axis resp
	% Examples
	% summaryTable = getSummaryInfo(trial_list, 200, 'AT_A19-2_2021-09-10_14-18-39_hfwr_auto_lighton_noisy_091021_218pm');
	% summaryTable = getSummaryInfo(trial_list, 200, 'AT_A19-2_2021-09-10_14-18-39_hfwr_auto_lighton_noisy_091021_218pm', 'right_d2_knuckle', 'aniposeData_fixed');

	if nargin<4
		bodyPart = 'right_d2_knuckle';
	end
	if nargin<5
		dataLabel = 'aniposeData_first_sc';
	end
	if nargin<6
		trialIndex = 1:length(trial_list);
	end

	% Start creating columns for the table
	label = repmat({outputLabel}, length(trialIndex), 1);
	trialIndex = reshape(trialIndex, length(trialIndex), 1);
	hitormiss = {};
	[hitormiss{1:length(trial_list)}] = deal(trial_list.hitormiss);
	hitormiss = cell2mat(hitormiss(trialIndex)');
	lightTrig = {};
	[lightTrig{1:length(trial_list)}] = deal(trial_list.lightTrig);
	lightTrig = lightTrig(trialIndex)';
	xDist = []; yDist = []; zDist = []; 
	totalDist = []; firstSCDist = [];
	xSpeed = []; ySpeed = []; zSpeed = []; averageSpeed = [];
	maxSpeed = []; distRelMaxSpeed = [];
	xyzSpeedPeakCount = []; jerkPeakCount = [];


	% Extract distance and speed from velocity table
	dt = 1/fs;
	% Init data labels to get relative dist data (only for total number of samples)
	distDataLabel = strcat(dataLabel, '_relative');
	% Init data labels to get speed and distance
	velDataLabel = strcat(dataLabel, '_relative_velocity');
	jerkDataLabel = strcat(dataLabel, '_relative_jerk');
	speedColLabel = strcat(bodyPart, '_xyzSpeed');
	xColLabel = strcat(bodyPart, '_x');
	yColLabel = strcat(bodyPart, '_y');
	zColLabel = strcat(bodyPart, '_z');
	rColLabel = strcat(bodyPart, '_r');
	for trial_idx = trialIndex'
		% Get speed and distance for every trial
		xRelTrial = [];
		xDistTrial = nan; yDistTrial = nan; zDistTrial = nan; totalDistTrial = nan;
		xSpeedTrial = nan; ySpeedTrial = nan; zSpeedTrial = nan; averageSpeedTrial = nan;
		if ~isempty(find(strcmpi(distDataLabel, fieldnames(trial_list(trial_idx)))))
		    if ~isempty(find(strcmpi(xColLabel,trial_list(trial_idx).(distDataLabel).Properties.VariableNames)))
		        xRelTrial = trial_list(trial_idx).(distDataLabel).(xColLabel);
		    end
		end
		if ~isempty(xRelTrial)
			totalTimeTrial = size(xRelTrial, 1)/fs;
			xyzSpeedTrialPt = abs(trial_list(trial_idx).(velDataLabel).(speedColLabel));
			[xyzSpeedTrialPeaks, xyzSpeedTrialLocs]  = findpeaks(xyzSpeedTrialPt);
			xyzSpeedTrialPeakCount = length(xyzSpeedTrialPeaks);
			xRelTrialPt = abs(trial_list(trial_idx).(distDataLabel).(xColLabel));
			yRelTrialPt = abs(trial_list(trial_idx).(distDataLabel).(yColLabel));
			zRelTrialPt = abs(trial_list(trial_idx).(distDataLabel).(zColLabel));
			if length(xRelTrial) > 1
				xDistTrial = sum(sqrt((xRelTrialPt(2:end) - xRelTrialPt(1:end-1)).^2));
				yDistTrial = sum(sqrt((yRelTrialPt(2:end) - yRelTrialPt(1:end-1)).^2));
				zDistTrial = sum(sqrt((zRelTrialPt(2:end) - zRelTrialPt(1:end-1)).^2));
				totalDistTrial = sum(sqrt((xRelTrialPt(2:end) - xRelTrialPt(1:end-1)).^2)+...
									   sqrt((yRelTrialPt(2:end) - yRelTrialPt(1:end-1)).^2)+...
									   sqrt((zRelTrialPt(2:end) - zRelTrialPt(1:end-1)).^2));
			else
				xDistTrial = 0;
				yDistTrial = 0;
				zDistTrial = 0;
				totalDistTrial = 0;
			end
			averageSpeedTrial = totalDistTrial/totalTimeTrial;
			firstSCRelDistLabel = 'aniposeData_first_sc_relative';
			% xyzRel is location wrt to ref (eg. spout)
			% Hence, r is dist to spout
			rRelFirstSCTrial = trial_list(trial_idx).(firstSCRelDistLabel).(rColLabel)(1);
			maxSpeedTrial = max(xyzSpeedTrialPt);
			max_loc = find(xyzSpeedTrialPt == maxSpeedTrial);
			rRelTrialMaxSpeed = trial_list(trial_idx).(distDataLabel).(rColLabel)(max_loc);
			xSpeedTrial = xDistTrial/totalTimeTrial;
			ySpeedTrial = yDistTrial/totalTimeTrial;
			zSpeedTrial = zDistTrial/totalTimeTrial;
			xJerkTrialPt = abs(trial_list(trial_idx).(jerkDataLabel).(xColLabel));
			yJerkTrialPt = abs(trial_list(trial_idx).(jerkDataLabel).(yColLabel));
			zJerkTrialPt = abs(trial_list(trial_idx).(jerkDataLabel).(zColLabel));
			jerkTrial = sqrt((xRelTrialPt(2:end) - xRelTrialPt(1:end-1)).^2)+...
						sqrt((yRelTrialPt(2:end) - yRelTrialPt(1:end-1)).^2)+...
						sqrt((zRelTrialPt(2:end) - zRelTrialPt(1:end-1)).^2);
			[jerkTrialPeaks, jerkTrialLocs]  = findpeaks(jerkTrial);
			jerkTrialPeakCount = length(jerkTrialPeaks);
		end
		xDist = [xDist; xDistTrial]; yDist = [yDist; yDistTrial]; zDist = [zDist; zDistTrial];
		totalDist = [totalDist; totalDistTrial]; firstSCDist = [firstSCDist; rRelFirstSCTrial];
		xSpeed = [xSpeed; xSpeedTrial]; ySpeed = [ySpeed; ySpeedTrial]; zSpeed = [zSpeed; zSpeedTrial];
		averageSpeed = [averageSpeed; averageSpeedTrial];
		maxSpeed = [maxSpeed; maxSpeedTrial]; distRelMaxSpeed = [distRelMaxSpeed; rRelTrialMaxSpeed];
		xyzSpeedPeakCount = [xyzSpeedPeakCount; xyzSpeedTrialPeakCount];
		jerkPeakCount = [jerkPeakCount; jerkTrialPeakCount];
	end
	summaryTable = table(label,...
						 trialIndex,...
						 hitormiss,...
						 lightTrig,...
						 xDist,...
						 yDist,...
						 zDist,...
						 totalDist,...
						 firstSCDist,...
						 xSpeed,...
						 ySpeed,...
						 zSpeed,...
						 averageSpeed,...
						 maxSpeed,...
						 distRelMaxSpeed,...
						 xyzSpeedPeakCount,...
						 jerkPeakCount);
end