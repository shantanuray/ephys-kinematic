%subplot average position, velocity, and emg from ETAdataFromStart code  
%velocity
%'Color',"#466c78"
%'Color',"#6fabbd"_average
figure;
subplot(7,1,2);
meanY = avg_dataFromStartSpeed;
seY = std_dataFromStartSpeed/sqrt(size(dataFromStartSpeed_sample,1));
X=1:length(avg_dataFromStartSpeed);
plot((1:length(avg_dataFromStartSpeed))*1000/videoSamplingRate,avg_dataFromStartSpeed,'Color',"#6fabbd",'lineWidth',2 );
hold on 
patch(([X fliplr(X)])*1000/videoSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
ylim([-100 50]);

%position
subplot(7,1,1);
meanY = avg_dataFromStartPosition;
seY = std_dataFromStartPosition/sqrt(size(dataFromStartPosition_sample,1));
X=1:length(avg_dataFromStartPosition);
plot((1:length(avg_dataFromStartPosition))*1000/videoSamplingRate,avg_dataFromStartPosition,'Color',"#6fabbd",'lineWidth',2 );
patch(([X fliplr(X)])*1000/videoSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
ylim([0 30]);

subplot(7,1,3);
meanY = avg_dataFromStartAcc;
seY = std_dataFromStartAcc/sqrt(size(dataFromStartAcc_sample,1));
X=1:length(avg_dataFromStartAcc);
plot((1:length(avg_dataFromStartAcc))*1000/videoSamplingRate,avg_dataFromStartAcc,'b','lineWidth',2 );
hold on 
patch(([X fliplr(X)])*1000/videoSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
ylim([-3500 3500]);

%biceps
subplot(7,1,4);
meanY = avg_dataFromStart_filtered_zscore;
seY = std_dataFromStart_filtered_zscore/sqrt(size(dataFromStartzscore_sample,1));
seD=std_dataFromStart_filtered_zscore;
X=1:length(avg_dataFromStart_filtered_zscore);
plot((1:length(avg_dataFromStart_filtered_zscore))*1000/ephysSamplingRate,avg_dataFromStart_filtered_zscore,'Color',[0 0.4470 0.7410],'lineWidth',2);
hold on 
patch(([X fliplr(X)])*1000/ephysSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
xlim([0 300]);

%triceps
%optobar and latency values is drawn in 
subplot(7,1,5);
meanY = avg_dataFromStart_filtered_zscore;
seY = std_dataFromStart_filtered_zscore/sqrt(size(dataFromStartzscore_sample,1));
seD=std_dataFromStart_filtered_zscore;
X=1:length(avg_dataFromStart_filtered_zscore);
plot((1:length(avg_dataFromStart_filtered_zscore))*1000/ephysSamplingRate,avg_dataFromStart_filtered_zscore,'Color',[0.6350 0.0780 0.1840],'lineWidth',2);
hold on 
patch(([X fliplr(X)])*1000/ephysSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
xlim([0 300]);

%trap"#82E0AA"/adelt "#34495E"
subplot(7,1,6);
meanY = avg_dataFromStart_filtered_zscore;
seY = std_dataFromStart_filtered_zscore/sqrt(size(dataFromStartzscore_sample,1));
seD=std_dataFromStart_filtered_zscore;
X=1:length(avg_dataFromStart_filtered_zscore);
plot((1:length(avg_dataFromStart_filtered_zscore))*1000/ephysSamplingRate,avg_dataFromStart_filtered_zscore,'Color', "#82E0AA",'lineWidth',2);
hold on 
patch(([X fliplr(X)])*1000/ephysSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
xlim([0 300]);

%ecu "#D2B4DE" /mdelt"#E59866"
subplot(7,1,7);
meanY = avg_dataFromStart_filtered_zscore;
seY = std_dataFromStart_filtered_zscore/sqrt(size(dataFromStartzscore_sample,1));
seD=std_dataFromStart_filtered_zscore;
X=1:length(avg_dataFromStart_filtered_zscore);
plot((1:length(avg_dataFromStart_filtered_zscore))*1000/ephysSamplingRate,avg_dataFromStart_filtered_zscore,'Color',"#D2B4DE",'lineWidth',2);
hold on 
patch(([X fliplr(X)])*1000/ephysSamplingRate, [meanY(:)-seY(:);flipud(meanY(:)+seY(:))],'k', 'FaceAlpha',0.15, 'EdgeColor','none');
xlim([0 300]);