save_loc='/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A34-2/figs/km_Subplots/acc_Peaks';

trialList=trialList_tone_on;
trialNum=23;
trial=trialList(trialNum);
plotColour='k';% k for light OFF, b for light ON 
processlabel = 'aniposeData_fixed_relative_acceleration';
processlabel_1='aniposeData_fixed_relative';
pose_ID='right_wrist_r';
trial_acc=abs([trial.(processlabel).([pose_ID])]);
trial_pose=([trial.(processlabel_1).([pose_ID])]);
 % below 1000 mm/s2, movements donts result in detectable displacement of the limb in the pose 
minPkheigth=1000;
[pk,loc,pkWidth,pkProm]=findpeaks(trial_acc,'MinPeakHeight',minPkheigth);
figure;
plot(trial_acc, plotColour,'LineWidth',1.5);
hold on;
plot(loc,pk,'o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5);
title('example#4 accPks');
saveas(gcf,fullfile(save_loc,'A34-2_2023-02-21_11-47-51_tone_on_trialNum_39_lowPass50'),'pdf');

