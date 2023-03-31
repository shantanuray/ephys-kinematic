function LightONtime_ms_trial =getLightONtime(trialList,trialNum)
%Calculate light ON time 
%works for one trial
trial=trialList(trialNum);
%calculates  light On time wrt to trial start in ms
LightONtime_ms_trial= (trial.lightOnTrig_ts(1)-(trial.start_ts+trial.reach_start_ts))*1000/30000;
