% enpoint values and mae for wrist and d3 knuckle 
trialNum=[]; 
trialList=trialList_tone_on;
wrist_endpoint=[];
d3_knuckle_endpoint=[];

for i=1:length(trialList)
    trial=trialList(i);
    [wrist_endpoint, d3_knuckle_endpoint]= getEndpoint(trial);
    wrist_endpoint(i)=wrist_endpoint;
    d3_knuckle_endpoint(i)=d3_knuckle_endpoint
end

mae_wrist_endpoint=mean(abs(wrist_endpoint));
mae_d3_knuckle_endpoint=mean(abs(d3_knuckle_endpoint));

