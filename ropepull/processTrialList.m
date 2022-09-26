% Then depending on the 'column' choose the appropriate method
colNames = {'trialXYZ',	'pathLength',	'speed',	'acceleration',	'azi',	'elev',	'trialXYZFirstPullData',	'trialXYZRhythymicPeakPreVhand_left',	'trialXYZRhythymicPeakPostVhand_left',	'trialXYZRhythymicPeakPreVhand_right',	'trialXYZRhythymicPeakPostVhand_right',	'speedFirstPullData',	'speedRhythymicPeakPreVhand_left',	'speedRhythymicPeakPostVhand_left',	'speedRhythymicPeakPreVhand_right',	'speedRhythymicPeakPostVhand_right',	'accelerationFirstPullData',	'accelerationRhythymicPeakPreVhand_left',	'accelerationRhythymicPeakPostVhand_left',	'accelerationRhythymicPeakPreVhand_right',	'accelerationRhythymicPeakPostVhand_right',	'aziFirstPullData',	'aziRhythymicPeakPreVhand_left',	'aziRhythymicPeakPostVhand_left',	'aziRhythymicPeakPreVhand_right',	'aziRhythymicPeakPostVhand_right',	'elevFirstPullData',	'elevRhythymicPeakPreVhand_left',	'elevRhythymicPeakPostVhand_left',	'elevRhythymicPeakPreVhand_right',	'elevRhythymicPeakPostVhand_right'}

fpath = 'C:\Users\shantanu.ray\projects\ephys-kinematic\data\ropepull\xyz_trialdata';
filepattern = 'CFL*analysis.mat';
dorsoVentralAxis = 'x';


trialList = importTrials(fpath, filepattern);
trialNum = 6;
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
data = squeeze(data); % (1600x3)

% To get only 'x'->1;'y'->2;'z'->3 for a particular nodeID
data = trial.(colName)(:,nodeID,1); % (1600x1)

[loc,pks,startPull,endPull] = getPeaks(trial, nodeName, dorsoVentralAxis, 0, 'MinPeakProminence', 0.1);
figure
plot(data);
hold on
plot(loc,pks,'rx') % plot the peaks
plot(trial.poseHeight)
% in case you want start and end of the pull
start_end_loc = [startPull, endPull];
start_end_value = trial.poseHeight(start_end_loc); % Mark them on the x-axis
plot(start_end_loc , start_end_value, 'bo')
plot(trial.poseHeight)
