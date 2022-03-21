function plot_computed(trial_list, dataLabels, bodyPart, fs, ref2max, save_fig, save_loc)
% Plots velocity/acceleration data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_computed(trial_list, dataLabels, bodyPart, ...
%                      fs, ...
%                      ref2max, ...
%                      savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed_relative_velocity'} or
%                     {'anipose_fixed_relative_velocity', 'anipose_first_sc_relative_velocity'}
%   - bodyPart: string with data label name or index position
%                 eg. 'left_wrist_x' or 'right_d2_knuckle_r'
%   - fs        : Sampling frequency
%   - ref2max: If true, normalize distance (v v/s d plot) wrt to distance at max velocity (Default: true)
%   - savefig: true to save figure automatically (Default: false)
%   - saveloc: if savefig is true, where to save the figures
%
% Example: plot_computed(trial_list, {'anipose_fixed_relative_velocity'}, 'right_d2_knuckle_r',...
%                        200, ...
%                        true, true, '/Users/chico/Desktop');


if nargin < 5
    ref2max = true;
end

if nargin<6
    save_fig = false;
end

if save_fig & nargin<7
    save_loc = uigetdir();
end


% Plot v vs t   
set(figure, 'color', [1 1 1]);
hold on;
%grid on;
xlabel ('time (sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
title_str = sprintf('Velocity-Time Plot for %s', bodyPart);
set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
plot_colors = {'k', 'g', 'b', 'c', 'm', 'y', 'r'};
% Loop over every trial
for trial_idx=1:length(trial_list)
    for dataLabel_idx = 1:length(dataLabels)
        plot_label = dataLabels{dataLabel_idx};
        plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
        num_frames = length(plot_data); 
        t = 1:num_frames; 
        if ref2max
           max_velocity = max(plot_data);
           max_loc = find(plot_data == max_velocity);
           t = t - max_loc;
        end
        t = t/fs; %time base
        if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
            plot(t, plot_data, 'r');
        else
            plot(t, plot_data, 'Color', [0 0.58 0.27]);
        end
    end
end
hold off
if save_fig
    saveas(gcf,fullfile(save_loc, strcat(replace(title_str, ' ', '_'), '.png')));
    close gcf;
end

 
% Plot v vs distance
set(figure, 'color', [1 1 1]);
hold on;
%grid on;
xlabel ('Distance (mm)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
title_str = sprintf('Velocity-Distance Plot for %s', bodyPart);
% title(title_str, 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial');
set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
set(gca,'XDir','reverse');

for trial_idx=1:length(trial_list)
    for dataLabel_idx = 1:length(dataLabels)
        plot_label = dataLabels{dataLabel_idx};
        % Assumption:
        %   if velocity label = 'anipose_fixed_relative_velocity'
        %   then distance label = 'anipose_fixed_relative'
        sep = strfind(plot_label, '_');
        dist_label = plot_label(1:sep(end)-1);
        plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
        dist_data = trial_list(trial_idx).(dist_label).(bodyPart);
        dist_data = dist_data(2:end,:);
        if ref2max
            max_velocity = max(plot_data);
            max_loc = find(plot_data == max_velocity);
            dist_at_max_vel = dist_data(max_loc);
            dist_data = dist_data - dist_at_max_vel;
        end
   
        if ~isempty(dist_data)
            dist_data(end)= [];
        end
        if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
            plot(dist_data, plot_data, 'r');
        else
            plot(dist_data, plot_data, 'Color', [0 0.58 0.27]);
        end
    end
end
hold off
if save_fig
    saveas(gcf,fullfile(save_loc, strcat(replace(title_str, ':', '_'), '_pre.png')));
    close gcf;
end