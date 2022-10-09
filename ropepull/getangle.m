function liftazi=getangle(trialList);
% for a list of trials gets the azimuth between two defined positions (in getreposition)
% e.g point1=start of pull segment
% point2= position at max Velocityfor the upward pulling segment 

liftazi=[];
colName='trialXYZRhythymicPeakPreVhand_right';
for i =1:length(trialList)
	trial = trialList(i);
  	[loc_data_start, loc_data_speed_max]=getrefposition(trial);
	data=trial.(colName).data;
	if isnan(data)
		azi = nan;
	else
		data_ref=data([loc_data_start loc_data_speed_max],:);
		data_ref=diff(data_ref);
		azi=rad2deg(cart2sph(data_ref(:,1),data_ref(:,2),data_ref(:,3)));
	end
	liftazi=[liftazi;azi];
end 