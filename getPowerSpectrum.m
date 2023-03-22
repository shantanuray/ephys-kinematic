% get power spectrum and plot 
trialList=trialList_tone_on;
trialNum=39;
trial=trialList(trialNum);
trialproperty=trial.aniposeData_fixed_relative_acceleration.(164)

[p,f]=pspectrum(trialproperty,200);
figure;
plot(f,p, 'k','LineWidth',1.5); 
