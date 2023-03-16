% get power spectrum and plot 
trialList=trialList_tone_on;
trialNum=39;
trial=trialList(trialNum);
trial.property=trial.EMG_trap_fixed;

[p,f]=pspectrum(trial.property,30000);
figure;
plot(f,p); 