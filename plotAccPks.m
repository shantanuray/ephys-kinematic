save_loc='/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A11-1/figs/km_Subplots/acc_Peaks';

trialList=trialList_tone_on;
trialNum=9;
trial=trialList(trialNum);
plotColour='k';% k for light OFF, b for light ON 
processlabel = 'aniposeData_fixed_relative_acceleration';
pose_ID='right_wrist_r';
trial_acc=abs([trial.(processlabel).([pose_ID])]);
% below 1000 mm/s2, movements donts result in detectable displacement of the limb in the pose 
minPkheigth=1000;
[pk,loc,pkWidth,pkProm]=findpeaks(trial_acc,'MinPeakHeight',minPkheigth);
figure;
plot(trial_acc, plotColour,'LineWidth',1.5);
ylabel('mm/s^2','FontSize',12);
xlabel('time(s)','FontSize',12);
hold on;
plot(loc,pk,'o','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5);
title('example#1 accPks');
saveas(gcf,fullfile(save_loc,'A11-1_2022-04-21_11-43-33_tone_on_trialNum_9_lowPass50'),'pdf');



