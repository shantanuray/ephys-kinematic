trialList=trialListGold_tone_on;
trialNum=2;
trial=trialList(trialNum);
pose_ID='right_wrist_r';

plotColour='k';% k for light OFF, b for light ON 
tdistP = 0:1/200:(size(trial.aniposeData_fixed_relative.(164))/200);
tdistV = 0:1/200:(size(trial.aniposeData_fixed_relative_velocity.(164))/200);
tdistJ = 0:1/200:(size(trial.aniposeData_fixed_relative_jerk.(164))/200);
trial_pose=[trial.aniposeData_fixed_relative.([pose_ID])];
trial_velocity=[trial.aniposeData_fixed_relative_velocity.([pose_ID])];
trial_jerk=[trial.aniposeData_fixed_relative_jerk.([pose_ID])];
figure;
%key 
%white circle spout contact
%red circle velocity minima closest to spout contact
% blue circle velocity minima closest to grip aperture 
%black circle start 
% red crosses velocity minima 
% red crosses jerk peaks 
%subplot(4,1,1);
plot(tdistP(1:end-1),trial_pose, plotColour, 'LineWidth', 2);
%ylim([0 30]);
ylabel('relative position','FontSize',12)
xlabel('time(s)')
hold on
plot(trial.reach_start_idx/200,trial_pose(trial.reach_start_idx),'o','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',5);
hold on
plot(trial.reach_end_idx/200,trial_pose(trial.reach_end_idx),'o','MarkerEdgeColor','k','MarkerFaceColor',"#0072BD",'MarkerSize',5);
hold on
plot(trial.grasp_start_idx/200,trial_pose(trial.grasp_start_idx),'o','MarkerEdgeColor','k','MarkerFaceColor',"#D95319",'MarkerSize',5);
hold on
plot(trial.grasp_end_idx/200,trial_pose(trial.grasp_end_idx),'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',5);

figure;plot(tdistV(1:end-1),trial_velocity);
figure;plot(trial_jerk);