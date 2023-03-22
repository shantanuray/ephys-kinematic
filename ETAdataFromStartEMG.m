dataFromStartFiltered=[];
dataFromStartzscore=[];

[b,a] = butter(4,[200,1000]/(ephysSamplingRate/2),'bandpass');
[b2,a2] = butter(4,50/(ephysSamplingRate/2),'low');
for i=1:length(trialList_tone_on)
    trial=trialList_tone_on(i);
        if  strcmpi(trial.lightTrig_fixed,'ON')

        %filter
        data_bp_filtered=filtfilt(b,a,trial.EMG_trap_fixed);
        data_rectified=abs(data_bp_filtered);
        data_low_filtered=filtfilt(b2,a2,data_rectified);
        
        %zscore
        data_low_filtered_zscore=zscore(data_low_filtered);

        %segment
        dataFromStart_filtered=data_low_filtered(1:(ephysSamplingRate*500/1000)-1);
        dataFromStart_filtered_zscore=data_low_filtered_zscore(1:(ephysSamplingRate*500/1000)-1);
        %fill variables 
        dataFromStartFiltered=[dataFromStartFiltered,dataFromStart_filtered];
 				dataFromStartzscore=[dataFromStartzscore,dataFromStart_filtered_zscore];

			end
end 

dataFromStartFiltered=dataFromStartFiltered';
dataFromStartzscore=dataFromStartzscore';
dataFromStartzscore_sample=dataFromStartzscore;%(25:40,:);
dataFromStartFiltered_sample=dataFromStartFiltered;%(25:40,:);
%Average
[avg_dataFromStart_filtered, std_dataFromStart_filtered] = getAverageDataArray(dataFromStartFiltered_sample);
[avg_dataFromStart_filtered_zscore, std_dataFromStart_filtered_zscore] = getAverageDataArray(dataFromStartzscore_sample);

%%plot
%plots the zscore over ms of individual trials and the average trial, use %bicep: 'Color',[0 0.4470 0.7410],tricep:'Color', [0.6350 0.0780 0.1840], %trap: 'Color' "#82E0AA", ecu:'Color' "#D2B4DE", mdelt:"#E59866", Adelt:"#34495E"  for color identification
%optobar and latency values is drawn in 
figure;
for i=1:size(dataFromStartzscore_sample,1)
    trial=dataFromStartzscore_sample(i, :);
    plot((1:length(trial))*1000/ephysSamplingRate,trial,'k','lineWidth',1)
    hold on 
end

hold on 
plot((1:length(avg_dataFromStart_filtered_zscore))*1000/ephysSamplingRate,avg_dataFromStart_filtered_zscore,'Color',"#34495E",'lineWidth',4 );
%xlim([averageOptolatency averageOptolatency+30]);
%ylim([-2 12]);

% figure;
% for i=1:size(dataFromStartFiltered_sample,1)
%     trial=dataFromStartFiltered_sample(i, :);
%     plot((1:length(trial))*1000/ephysSamplingRate,trial,'k','lineWidth',1)
%     hold on 
% end

% hold on 
% plot((1:length(avg_dataFromStart_filtered))*1000/ephysSamplingRate,avg_dataFromStart_filtered,'Color',"#D2B4DE",'lineWidth',4 );
% xlim([0 500]);

