% Then depending on the 'column' choose the appropriate method
colNames = {'trialXYZ',	'pathLength',	'speed',	'acceleration',	'azi',	'elev',	'trialXYZFirstPullData',	'trialXYZRhythymicPeakPreVhand_left',	'trialXYZRhythymicPeakPostVhand_left',	'trialXYZRhythymicPeakPreVhand_right',	'trialXYZRhythymicPeakPostVhand_right',	'speedFirstPullData',	'speedRhythymicPeakPreVhand_left',	'speedRhythymicPeakPostVhand_left',	'speedRhythymicPeakPreVhand_right',	'speedRhythymicPeakPostVhand_right',	'accelerationFirstPullData',	'accelerationRhythymicPeakPreVhand_left',	'accelerationRhythymicPeakPostVhand_left',	'accelerationRhythymicPeakPreVhand_right',	'accelerationRhythymicPeakPostVhand_right',	'aziFirstPullData',	'aziRhythymicPeakPreVhand_left',	'aziRhythymicPeakPostVhand_left',	'aziRhythymicPeakPreVhand_right',	'aziRhythymicPeakPostVhand_right',	'elevFirstPullData',	'elevRhythymicPeakPreVhand_left',	'elevRhythymicPeakPostVhand_left',	'elevRhythymicPeakPreVhand_right',	'elevRhythymicPeakPostVhand_right'}

fpath = '/Users/ayesha/Dropbox/Ayesha_post doc_local storage/temp files/RP_SLEAP_training_mat';
filepattern = 'CFL*analysis.mat';
dorsoVentralAxis = 'x';


trialList = importTrials(fpath, filepattern);
		trialNum = 16;
		trial = trialList(trialNum);

		% Get all data for colName
		% Choose col name from above (example: acceleration) 
		colName = 'trialXYZ';
		% Get data
		data = trial.(colName);
		% To get for a particular node
		nodeName = 'hand_right';
		nodeNames = trial.markerNames;
		nodeID = searchStrInCell(nodeNames, nodeName);
		data = trial.(colName)(:,nodeID,:); % (1600x1x3)
		%data = squeeze(data); % (1600x3)
		%data_pathLength=data;
		%plot(data_pathLength);
		%data_elev=data;
		%data_speed=data;
		% To get only 'x'->1;'y'->2;'z'->3 for a particular nodeID
		data_dv = trial.(colName)(:,nodeID,1); % (1600x1)
		data_ml = trial.(colName)(:,nodeID,2); % (1600x1)
		data_ap = trial.(colName)(:,nodeID,3); % (1600x1)
		figure; plot(1:length(data_dv),data_dv,'k', 'LineWidth',1.5);
	xlim([0 2]);
	ylim([-20 60]);

% plot data_dv,data_ml,data_ap
figure;
subplot(3,1,1);
plot((1:length(data_dv))/200, -data_dv,'k', 'LineWidth',4);
xlim([2.5 3.5]);
%ylim([-60 0]);
subplot(3,1,2);
plot((1:length(data_ml))/200, data_ml,'k', 'LineWidth',4);
xlim([2.5 3.5]);
%ylim([-4 4]);
subplot(3,1,3);
plot((1:length(data_ap))/200, data_ap, 'k', 'LineWidth',4);
xlim([2.5 3.5]);
%ylim([135 155]);

% plot data_azi, elev
figure;
	subplot(2,1,1);
	plot((1:length(data_elev))/200,data_elev, 'r', 'LineWidth',1.5);
	xlim([1.5 3]);	
	%ylim([-1.5 1])
	subplot(2,1,2);
	plot((1:length(data_azi))/200,data_azi, 'r', 'LineWidth',1.5);
	xlim([1.5 3]);
subplot(3,1,3);
plot((1:length(data_speed))/200,data_speed, 'k', 'LineWidth',1.5);
xlim([1 2]);	

[loc,pks,startPull,endPull] = getPeaks(trial, nodeName, dorsoVentralAxis, 0, 'MinPeakProminence', 0.2);
figure
plot((1:length(data))/200, data);
hold on
plot(loc/200,pks,'rx') % plot the peaks
plot((1:length(data))/200,trial.poseHeight)
% in case you want start and end of the pull
start_end_loc = [startPull, endPull];
start_end_value = trial.poseHeight(start_end_loc); % Mark them on the x-axis
plot(start_end_loc/200 , start_end_value, 'bo')
plot((1:length(data))/200,trial.poseHeight)

