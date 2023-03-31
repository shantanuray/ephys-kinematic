function summaryTable = getSummaryInfo_03272023(trial_list, fs, outputLabel, bodyPart, processlabel, trialIndex)
	% summaryTable = getSummaryInfo(trial_list, fs, outputLabel, bodyPart, processlabel, trialIndex)
	% Create summary table for set of trials of given experiment
	% Input:
	%   - trial_list: list of segmented trials with reach data and velicoty, speed information
	%	- fs:  (float) Sampling frequency
	%	- outputLabel: (str) Label for the entire experiment
	%   - bodyPart: (str) body part label (Default) {'right_d2_knuckle'}
	%	- processlabel: (str) Data table to use for computation (Default: 'aniposeData_first_sc')
	%				Values can be:
	%					* 'aniposeData_fixed'
	%					* 'aniposeData_reach'
	%                   * 'aniposeData_grasp'
	%	- trialIndex: (int array) index of trials to include in summary (Default: 1:length(trial_list))
	% Output:
	%	- summaryTable: Table with columns:
	% Examples
	% summaryTable = getSummaryInfo_03272023(trialList_tone_on, 200, 'A11-1', 'right_wrist', 'aniposeData_reach');

	if nargin<4
		bodyPart = 'right_wrist';
	end
	if nargin<5
		processlabel = 'aniposeData_reach';
	end
	if nargin<6
		trialIndex = 1:length(trial_list);
	end

	% Start creating columns for the table
	label = {};
	trialIndex = [];
	hitormiss = [];
	lightTrig = {};
	xDist = []; yDist = []; zDist = []; 
	totalDist = [];
	xSpeed = []; ySpeed = []; zSpeed = []; averageSpeed = [];
	maxSpeed = []; distRelMaxSpeed = [];
	totalTimeTrialOut = [];
	azi_reachAngle = [];elev_reachAngle = [];
	azi_aimAngle = [];elev_aimAngle = [];
	wrist_endpoint=[]; right_d3_knuckle_endpoint=[];
	start_r=[];start_AP=[];start_ML=[];start_DV=[];
   tortuosity=[];
   accPk_count=[]; accPk_meanAmp=[]; accPk_maxAmp=[]; accPk_meanProm=[]; accPk_maxProm=[];
   accPk_meanWidth=[]; accPk_maxWidth=[]; accPk_freq=[]; acc_period=[];
   LightONtime_ms=[];
   displacementThreshold=[];
   %define inputs to functions for caluclulating data
	% Extract distance and speed from velocity table
	dt = 1/fs;
	% Init data labels to get relative dist data (only for total number of samples)
	%distDataLabel='aniposeData_reach_relative';
	poseIDAngleRefPosition='right_wrist';
	poseID_endPointref2='right_d3_knuckle_r';
	distDataLabel = strcat(processlabel, '_relative');
	% Init data labels to get speed and distance
	velDataLabel = strcat(processlabel, '_relative_velocity');
	jerkDataLabel = strcat(processlabel, '_relative_jerk');
	speedColLabel = strcat(bodyPart, '_xyzSpeed');
	xColLabel = strcat(bodyPart, '_x');
	yColLabel = strcat(bodyPart, '_y');
	zColLabel = strcat(bodyPart, '_z');
	rColLabel = strcat(bodyPart, '_r');
   minPkheigth=1000;
    %calculate all values and return column vectors
	for trial_idx = 1:length(trial_list)
		trial = trial_list(trial_idx);
		label{trial_idx, 1} = outputLabel;
		trialIndex = [trialIndex; trial_idx];
		hitormiss = [hitormiss; trial.hitormiss];
		displacementThreshold=[displacementThreshold;trial.displacementThreshold];
		% on/off
		lightTrig{trial_idx, 1} = trial.lightTrig;
   	speedMax_idx=getPositionMaxSpeed(trial);
   	endPos=find(trial.(distDataLabel).(rColLabel) == trial.(distDataLabel).(rColLabel)(end));
		[azi_1,elev_1]=getAngleRefPosition(trial,distDataLabel,poseIDAngleRefPosition,1,endPos);
		[azi_2,elev_2]=getAngleRefPosition(trial,distDataLabel,poseIDAngleRefPosition,1,speedMax_idx);
		% Get speed and distance for every trial
		xDistTrial = nan; yDistTrial = nan; zDistTrial = nan; totalDistTrial = nan;
		xSpeedTrial = nan; ySpeedTrial = nan; zSpeedTrial = nan; averageSpeedTrial = nan;
		xRelTrial = trial.(distDataLabel).(xColLabel);
		totalTimeTrial = nan;
		totalTimeTrial = size(xRelTrial, 1)/fs;
		xyzSpeedTrialPt = abs(trial.(velDataLabel).(speedColLabel));
		% if length(xyzSpeedTrialPt) >= 3
		% 	[xyzSpeedTrialPeaks, xyzSpeedTrialLocs]  = findpeaks(xyzSpeedTrialPt);
		% else
		% 	xyzSpeedTrialPeaks = [];
		% 	xyzSpeedTrialLocs = [];
		% end
		% xyzSpeedTrialPeakCount = length(xyzSpeedTrialPeaks);
		xRelTrialPt = abs(trial.(distDataLabel).(xColLabel));
		yRelTrialPt = abs(trial.(distDataLabel).(yColLabel));
		zRelTrialPt = abs(trial.(distDataLabel).(zColLabel));
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
		maxSpeedTrial = max(xyzSpeedTrialPt);
		distRelMaxSpeed_trial=trial.(distDataLabel).(rColLabel)(speedMax_idx);
		xSpeedTrial = xDistTrial/totalTimeTrial;
		ySpeedTrial = yDistTrial/totalTimeTrial;
		zSpeedTrial = zDistTrial/totalTimeTrial;
      wrist_endpoint_trial=trial.(distDataLabel).(rColLabel)(endPos);
      right_d3_knuckle_endpoint_trial=trial.(distDataLabel).(poseID_endPointref2)(endPos);
      start_AP_trial = trial.(distDataLabel).(xColLabel)(1);
      start_ML_trial = trial.(distDataLabel).(yColLabel)(1);
      start_DV_trial = trial.(distDataLabel).(zColLabel)(1);
      start_r_trial=trial.(distDataLabel).(rColLabel)(1);
      tortuosity_trial=getTortuosity(trial,distDataLabel,rColLabel);
      [accPk_count_trial, accPk_meanAmp_trial, accPk_maxAmp_trial, accPk_meanProm_trial, accPk_maxProm_trial,accPk_meanWidth_trial, accPk_maxWidth_trial,accPk_freq_trial,acc_period_trial]=getAccPkInfo(trial);
        if strcmpi(trial.lightTrig,'ON')
           LightONtime_ms_trial= (trial.lightOnTrig_ts(1)-(trial.start_ts+trial.reach_start_ts))*1000/30000;
        elseif strcmpi(trial.lightTrig,'OFF')
           LightONtime_ms_trial=nan;
        end

      % build the columns 
		totalTimeTrialOut = [totalTimeTrialOut; totalTimeTrial];
		xDist = [xDist; xDistTrial]; yDist = [yDist; yDistTrial]; zDist = [zDist; zDistTrial];
		totalDist = [totalDist; totalDistTrial]; 
		xSpeed = [xSpeed; xSpeedTrial]; ySpeed = [ySpeed; ySpeedTrial]; zSpeed = [zSpeed; zSpeedTrial];
		averageSpeed = [averageSpeed; averageSpeedTrial];
		maxSpeed = [maxSpeed; maxSpeedTrial]; distRelMaxSpeed = [distRelMaxSpeed;distRelMaxSpeed_trial];
		wrist_endpoint=[wrist_endpoint;wrist_endpoint_trial];
      right_d3_knuckle_endpoint=[right_d3_knuckle_endpoint;right_d3_knuckle_endpoint_trial];
      azi_reachAngle = [azi_reachAngle;azi_1];
		elev_reachAngle = [elev_reachAngle;elev_1];
		azi_aimAngle=[azi_aimAngle;azi_2];
		elev_aimAngle=[elev_aimAngle;elev_2];
      start_AP=[start_AP;start_AP_trial];
      start_ML=[start_ML;start_ML_trial];
      start_DV=[start_DV;start_DV_trial];
      start_r=[start_r;start_r_trial];
		tortuosity=[tortuosity;tortuosity_trial];
		accPk_count=[accPk_count;accPk_count_trial]; 
		accPk_meanAmp=[accPk_meanAmp;accPk_meanAmp_trial];
		accPk_maxAmp=[accPk_maxAmp;accPk_maxAmp_trial]; 
		accPk_meanProm=[accPk_meanProm;accPk_meanProm_trial];
		accPk_maxProm=[accPk_maxProm;accPk_maxProm_trial]; 
		accPk_meanWidth=[accPk_meanWidth;accPk_meanWidth_trial]; 
		accPk_maxWidth=[accPk_maxWidth;accPk_maxWidth_trial]; 
		accPk_freq=[accPk_freq;accPk_freq_trial]; 
		acc_period=[acc_period;acc_period_trial];
		LightONtime_ms=[LightONtime_ms;LightONtime_ms_trial];
	end
	% build table 
	summaryTable = table(label,...
						 trialIndex,...
						 hitormiss,...
						 lightTrig,...
						 LightONtime_ms,...
						 displacementThreshold,...
						 xDist,...
						 yDist,...
						 zDist,...
						 totalDist,...
						 xSpeed,...
						 ySpeed,...
						 zSpeed,...
						 averageSpeed,...
						 maxSpeed,...
						 distRelMaxSpeed,...
						 totalTimeTrialOut,...
						 azi_reachAngle,...
						 elev_reachAngle,...
                   azi_aimAngle,...
                   elev_aimAngle,... 
	                wrist_endpoint,...
	                right_d3_knuckle_endpoint,...
                   start_r,...
                   start_AP,...
                   start_ML,...
                   start_DV,...
                   tortuosity,...
                   accPk_count,...
                   accPk_meanAmp,...
                   accPk_maxAmp,...
                   accPk_meanProm,...
                   accPk_maxProm,...
                   accPk_meanWidth,...
                   accPk_maxWidth,...
                   accPk_freq,...
                   acc_period);
end