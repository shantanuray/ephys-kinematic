%subplot start and end point 
%plots the start and end point locations based on velocity minima and grip aperture, and subplots all the relevant derivative information with their peak values
% this code must follow the calling function for start end etc  
save_loc='/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A34-2/figs/km_Subplots/start_endpoint';

plotColour='k';% k for light OFF, b for light ON 
tdistP = 0:1/200:(size(trial.aniposeData_fixed_relative.(164))/200);
tdistV = 0:1/200:(size(trial.aniposeData_fixed_relative_velocity.(164))/200);
tdistJ = 0:1/200:(size(trial.aniposeData_fixed_relative_jerk.(164))/200);

figure;
%key 
%white circle spout contact
%red circle velocity minima closest to spout contact
% blue circle velocity minima closest to grip aperture 
%black circle start 
% red crosses velocity minima 
% red crosses jerk peaks 
subplot(4,1,1);
plot(tdistP(1:end-1),trial_pose, plotColour, 'LineWidth', 2);
%ylim([0 30]);
ylabel('relative position','FontSize',12)
xlabel('time(s)')
hold on
plot(first_sc_idx/200,trial_pose(first_sc_idx),'o','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',5);
hold on
plot(VelocityMinimagripAperture_endpoint_idx/200,trial_pose(VelocityMinimagripAperture_endpoint_idx),'o','MarkerEdgeColor','k','MarkerFaceColor',"#0072BD",'MarkerSize',5);
hold on
plot(VelocityMinimafirst_sc_endpoint_idx/200,trial_pose(VelocityMinimafirst_sc_endpoint_idx),'o','MarkerEdgeColor','k','MarkerFaceColor',"#D95319",'MarkerSize',5);
hold on
plot(startPos/200,trial_pose(startPos),'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',5);

subplot(4,1,2);
plot(tdistV(1:end-1),trial_velocity, plotColour, 'LineWidth', 2);
%ylim([-400 400]);
ylabel('relative speed','FontSize',12)
xlabel('time(s)')
hold on
plot(velocityMinima_idx/200,trial_velocity(velocityMinima_idx),'x','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5,'LineWidth',1)

subplot(4,1,3);
plot(tdistJ(1:end-1),trial_jerk, plotColour, 'LineWidth', 2);
%ylim([-400 400]);
ylabel('relative jerk','FontSize',12)
xlabel('time(s)')
hold on
plot(jerkloc/200,trial_jerk(jerkloc),'x','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5,'LineWidth',1)

subplot(4,1,4);
plot(tdistP(1:end-1), gripAperture, plotColour, 'LineWidth', 2);
%ylim([-20000 20000]);
ylabel('gripAperture','FontSize',12)
xlabel('time(s)')
hold on
plot(gripAperture_max_idx/200,gripAperture(gripAperture_max_idx), 'x','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5,'LineWidth',1);

sgtitle('example#4 start_endpoint');

saveas(gcf,fullfile(save_loc,'A34-2_2023-02-21_11-47-51_tone_on_lowPass50_trial_39_start_endpoint'),'pdf');