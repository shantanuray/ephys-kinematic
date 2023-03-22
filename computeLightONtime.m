%Calculate light ON time 
trialList=trialList_tone_on;
trialNum=13;
trial=trialList(trialNum);
%calculates  light On time wrt to trial start in ms
LightON=(trial.start_ts-trial.lightOnTrig_ts_fixed(1))*1000/30000; 