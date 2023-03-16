%plot position, velocity, acceleration of specific example trials 
%change 
%colour of plot 
%figure tittle
%plot, filename
%file path for saving 
save_loc='/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A34-2/figs/figsForFiltering';

trialList=trialList_tone_on;
trialNum=39;
trial=trialList(trialNum);
plotColour='b';% k for light OFF, b for light ON 

tdistP = 0:1/200:(size(trial.aniposeData_fixed_relative.(212))/200);
tdistV = 0:1/200:(size(trial.aniposeData_fixed_relative_velocity.(212))/200);
tdistA = 0:1/200:(size(trial.aniposeData_fixed_relative_acceleration.(212))/200);

figure;
subplot(3,1,1);
plot(tdistP(1:end-1), trial.aniposeData_fixed_relative.(212),plotColour, 'LineWidth', 2);
ylim([0 30]);
ylabel('relative position','FontSize',12)
xlabel('time(s)')
subplot(3,1,2);
plot(tdistV(1:end-1), -trial.aniposeData_fixed_relative_velocity.(212),plotColour, 'LineWidth', 2);
ylim([-400 400]);
ylabel('relative speed','FontSize',12)
xlabel('time(s)')
subplot(3,1,3);
plot(tdistA(1:end-1), -trial.aniposeData_fixed_relative_acceleration.(212),plotColour, 'LineWidth', 2);
ylim([-20000 20000]);
ylabel('relative acceleration','FontSize',12)
xlabel('time(s)')
sgtitle('example#4 filtered');

saveas(gcf,fullfile(save_loc,'A34-2_2023-02-21_11-47-51_tone_on_trialNum_39_filtered'),'pdf');
