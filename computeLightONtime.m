%Calculate light ON time 
trialList=trialList_tone_on;
trialNum=13;
trial=trialList(trialNum);
%calculates  light On time wrt to trial start in ms
LightONtime_ms= (trial.lightOnTrig_ts(1)-(trial.start_ts+trial.reach_start_ts)*1000/30000;