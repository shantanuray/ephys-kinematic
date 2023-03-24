function [accPk_count, accPk_meanAmp, accPk_maxAmp, accPk_meanProm, accPk_maxProm, accPk_meanWidth, accPk_maxWidth,accPk_freq,acc_period]=getAccPkInfo(trial,processlabel,minPkheigth)
%get acceleration peak data 
% #
% mean amplitude, 
% max amplitude, 
% mean prominance, 
% max prominance, 
% mean width,
% maxwidth, 
if nargin < 3
        minPkheigth=1000;
end
minPkheigth=1000;
if nargin < 2
        processlabel = 'aniposeData_fixed_relative_acceleration';
end
pose_ID='right_wrist_r';

trial_acc=abs([trial.(processlabel).([pose_ID])]);
[pk,loc,pkWidth,pkProm]=findpeaks(trial_acc);
minPkheigth=1000;
[pk,loc,pkWidth,pkProm]=findpeaks(trial_acc,'MinPeakHeight',minPkheigth);
accPk_count=length(pk);
accPk_meanAmp=mean(pk);
accPk_maxAmp=max(pk);
accPk_meanProm=mean(pkProm);
accPk_maxProm=max(pkProm);
accPk_meanWidth=mean(pkWidth);
accPk_maxWidth=max(pkWidth);
accPk_freq= length(pk)/(((length(trial_acc))/200)+0.02);
acc_period=1/accPk_freq;


