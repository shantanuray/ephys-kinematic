save_loc='/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A11-1/figs/km_Subplots/pspectrum';
trialList=trialList_tone_on;
trialNum=9;
trial=trialList(trialNum);
plotColour='k';% k for light OFF, b for light ON 
processlabel = 'aniposeData_fixed_relative_acceleration';
pose_ID='right_wrist_r';
trial_acc=[trial.(processlabel).([pose_ID])];
[p,f]=pspectrum(trial_acc,200);

figure;
plot(f,p, plotColour,'LineWidth',1.5); 
ylabel('dB','FontSize',12);
xlabel('hz','FontSize',12);
title('example#1 pspectrum');
saveas(gcf,fullfile(save_loc,'A11-1_2022-04-21_11-43-33_tone_on_trialNum_9_lowPass50'),'pdf');