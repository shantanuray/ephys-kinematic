function elbowAngleatMaxSpeed = getelbowAngleatMaxSpeed(trialList);
% for a list of trials gets the azimuth between two defined positions (in getreposition)
% e.g point1=start of pull segment
% point2= position at max Velocityfor the upward pulling segment 

elbowAngleatMaxSpeed=[];

colName='elbowAngleRhythymicPeakPreVhand_right';
for i =1:length(trialList)
	trial = trialList(i);
  	[loc_data_start, loc_data_speed_max]=getrefposition(trial);
	data=trial.(colName).data;

	if ~isnan(data)
		  elbowAngle=data(loc_data_speed_max);
	else
		  elbowAngle=nan;
	end

	elbowAngleatMaxSpeed = [elbowAngleatMaxSpeed;elbowAngle];
end 


