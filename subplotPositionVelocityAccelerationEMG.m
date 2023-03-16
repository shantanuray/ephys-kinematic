%plot position, velocity, acceleration and EMGs of specific example trials 
%variables that change 
%colour of plot 
%figure tittle
%plot, filename
%file path for saving 
save_loc='/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A34-2/figs/exampleTrials';

trialList=trialList_tone_on;
trialNum=8;
trial=trialList(trialNum);
plotColour='k';% k for light OFF, b for light ON 
[b,a] = butter(4,[200,1000]/(ephysSamplingRate/2),'bandpass');
[b2,a2] = butter(4,50/(ephysSamplingRate/2),'low');

%biceps
data_biceps_filtered=filtfilt(b,a,trial.EMG_biceps_fixed);
data_biceps_rectified=abs(data_biceps_filtered);
data_biceps_lowfiltered=filtfilt(b2,a2,data_biceps_rectified);

%triceps
data_triceps_filtered=filtfilt(b,a,trial.EMG_triceps_fixed);
data_triceps_rectified=abs(data_triceps_filtered);
data_triceps_lowfiltered=filtfilt(b2,a2,data_triceps_rectified);

%ecu/ mid delt/ contra Triceps, specific for each mouse 
data_ecu_filtered=filtfilt(b,a,trial.EMG_ecu_fixed);
data_ecu_rectified=abs(data_ecu_filtered);
data_ecu_lowfiltered=filtfilt(b2,a2,data_ecu_rectified);

%trap/Adelt/specific for each mouse 
data_trap_filtered=filtfilt(b,a,trial.EMG_trap_fixed);
data_trap_rectified=abs(data_trap_filtered);
data_trap_lowfiltered=filtfilt(b2,a2,data_trap_rectified);

tdistP = 0:1/200:(size(trial.aniposeData_fixed_relative.(212))/200);
tdistV = 0:1/200:(size(trial.aniposeData_fixed_relative_velocity.(212))/200);
tdistA = 0:1/200:(size(trial.aniposeData_fixed_relative_acceleration.(212))/200);
tephys = 0:1/30000:size(trial.EMG_biceps_fixed, 1)/30000;


figure;
subplot(7,1,1);
plot(tdistP(1:end-1), trial.aniposeData_fixed_relative.(212),plotColour, 'LineWidth', 2);
%ylim([0 30]);
ylabel('relative position','FontSize',12)
xlabel('time(s)')
subplot(7,1,2);
plot(tdistV(1:end-1), -trial.aniposeData_fixed_relative_velocity.(212),plotColour, 'LineWidth', 2);
%ylim([-400 400]);
ylabel('relative speed','FontSize',12)
xlabel('time(s)')
subplot(7,1,3);
plot(tdistA(1:end-1), -trial.aniposeData_fixed_relative_acceleration.(212),plotColour, 'LineWidth', 2);
ylim([-10000 10000]);
ylabel('relative acceleration','FontSize',12)
xlabel('time(s)')
subplot(7,1,4);
plot(tephys(1:end-1),data_biceps_lowfiltered,plotColour,'LineWidth',2);
ylim([0 0.015]);
ylabel('triceps(mV)','FontSize',12)
xlabel('time(s)')
subplot(7,1,5);
plot(tephys(1:end-1),data_triceps_lowfiltered,plotColour,'LineWidth',2);
ylim([0 0.4]);
ylabel('biceps(mV)','FontSize',12)
xlabel('time(s)')
subplot(7,1,6);
plot(tephys(1:end-1),data_trap_lowfiltered,plotColour,'LineWidth',2);
ylim([0 0.03]);
ylabel('antDelt(mV)','FontSize',12)
xlabel('time(s)')
subplot(7,1,7);
plot(tephys(1:end-1),data_ecu_lowfiltered,plotColour,'LineWidth',2);
ylim([0 0.02]);
ylabel('contraTri(mV)','FontSize',12)
xlabel('time(s)')

sgtitle('A34-2 Light-OFF example #1 50hz');

saveas(gcf,fullfile(save_loc,'A34-2_2023-02-17_14-25-51_lightoff_tone_on_filtered_trialNum_8'),'pdf');
