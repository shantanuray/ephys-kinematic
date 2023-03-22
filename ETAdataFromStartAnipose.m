dataFromStartSpeed=[];
dataFromStartPosition=[];
dataFromStartAcc=[];
videoSamplingRate=200;
for i=1:length(trialList_tone_on)
    trial=trialList_tone_on(i);
    if  strcmpi(trial.lightTrig_fixed,'OFF')
        speed=trial.aniposeData_fixed_relative_velocity.(212);
        r=trial.aniposeData_fixed_relative.(212);
        acc=trial.aniposeData_fixed_relative_acceleration.(212);
        %segment
        %fill variables 
        dataFromStartSpeed=[dataFromStartSpeed,speed];
        dataFromStartPosition=[dataFromStartPosition,r];
        dataFromStartAcc=[dataFromStartAcc,acc];
	end
end 

dataFromStartSpeed=dataFromStartSpeed';
dataFromStartPosition=dataFromStartPosition';
dataFromStartAcc=dataFromStartAcc';
dataFromStartSpeed_sample=dataFromStartSpeed;%(25:40,:);
dataFromStartPosition_sample=dataFromStartPosition;%(25:40,:);
dataFromStartAcc_sample=dataFromStartAcc;%(25:40,:);
%Average
[avg_dataFromStartSpeed, std_dataFromStartSpeed] = getAverageDataArray(dataFromStartSpeed_sample);
[avg_dataFromStartPosition, std_dataFromStartPosition] =getAverageDataArray(dataFromStartPosition_sample);
[avg_dataFromStartAcc, std_dataFromStartAcc] = getAverageDataArray(dataFromStartAcc_sample);

%%plot
%plots the zscore over ms of individual trials and the average trial, use %bicep: 'Color',[0 0.4470 0.7410],tricep:'Color', [0.6350 0.0780 0.1840], %trap: 'Color' "#82E0AA", ecu:'Color' "#D2B4DE", mdelt:"#E59866", Adelt:"#34495E"  for color identification, lightON:single trials,"#466c78", average "#6fabbd", light OFF:K
%optobar and latency values is drawn in 
% figure;
% subplot(2,1,1);
% for i=1:size(dataFromStartSpeed_sample,1)
%     trial=dataFromStartSpeed_sample(i, :);
%     plot((1:length(trial))*1000/videoSamplingRate,trial,'Color',"#466c78",'lineWidth',1)
%     hold on 
% end
% hold on 
% plot((1:length(avg_dataFromStartSpeed))*1000/videoSamplingRate,avg_dataFromStartSpeed,'Color', "#6fabbd",'lineWidth',4 );
% xlim([0 500]);
% subplot(2,1,2);
% for i=1:size(dataFromStartPosition_sample,1)
%     trial=dataFromStartPosition_sample(i, :);
%     plot((1:length(trial))*1000/videoSamplingRate,trial,'Color',"#466c78",'lineWidth',1)
%     hold on 
% end
% hold on 
% plot((1:length(avg_dataFromStartPosition))*1000/videoSamplingRate,avg_dataFromStartPosition,'Color', "#6fabbd",'lineWidth',4 );
% xlim([0 500]);


