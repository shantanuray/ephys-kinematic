function plot_computed(trial_list, dataLabels, bodyPart, fs, ref2max, annotateON, save_fig, save_loc)
% Plots velocity/acceleration data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_computed(trial_list, dataLabels, bodyPart, ...
%                      fs, ...
%                      ref2max,annotateON,...
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
%   - annotateON: If true, mark when light ON (default: true)
%   - savefig: true to save figure automatically (Default: false)
%   - saveloc: if savefig is true, where to save the figures
%
% Example: plot_computed(trial_list, {'anipose_fixed_relative_velocity'}, 'right_d2_knuckle_r',...
%                        200, true, true, ...
%                        true, '/Users/chico/Desktop');


if nargin < 5
    ref2max = true;
end

if nargin<6
    annotateON = true;
end

if nargin<7
    save_fig = false;
end

if save_fig & nargin<8
    save_loc = uigetdir();
end

for dataLabel_idx = 1:length(dataLabels)
    plot_label = dataLabels{dataLabel_idx};
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        title_str = sprintf('Velocity-Time Plot for %s', bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        title_str = sprintf('Acceleration-Time Plot for %s', bodyPart);
    else
        n = 0;
    end
    % Plot data vs t   
    set(figure, 'color', [1 1 1]);
    hold on;
    %grid on;
    xlabel ('time (sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
    plot_colors = {'k', 'g', 'b', 'c', 'm', 'y', 'r'};
    
    % Loop over every trial
    for trial_idx=1:length(trial_list)
        plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
        if ~isempty(plot_data)
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
                if annotateON
                    lightOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                    plot(t(lightOn_idx), plot_data(lightOn_idx),'ro',...
                        'MarkerEdgeColor','k',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            else
                plot(t, plot_data, 'Color', [0 0.58 0.27]);
            end
        end
    end
end
hold off
if save_fig
    saveas(gcf,fullfile(save_loc, strcat(replace(title_str, ' ', '_'), '.png')));
    close gcf;
end

for dataLabel_idx = 1:length(dataLabels)
    plot_label = dataLabels{dataLabel_idx};
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        title_str = sprintf('Velocity-Time Plot for %s', bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        title_str = sprintf('Acceleration-Time Plot for %s', bodyPart);
    else
        n = 0;
    end
    % Plot data vs distance
    set(figure, 'color', [1 1 1]);
    hold on;
    %grid on;
    xlabel ('Distance (mm)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    % title(title_str, 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial');
    set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
    set(gca,'XDir','reverse');

    % Assumption:
    %   if velocity label = 'anipose_fixed_relative_velocity'
    %   then distance label = 'anipose_fixed_relative'
    sep = strfind(plot_label, '_');
    dist_label = plot_label(1:sep(end)-1);
    for trial_idx=1:length(trial_list)
        plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
        if ~isempty(plot_data)
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
                if annotateON
                    lightOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                    plot(dist_data(lightOn_idx), plot_data(lightOn_idx), 'ro',...
                        'MarkerEdgeColor','k',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            else
                plot(dist_data, plot_data, 'Color', [0 0.58 0.27]);
            end
        end
    end
end
hold off
if save_fig
    saveas(gcf,fullfile(save_loc, strcat(replace(title_str, ':', '_'), '_pre.png')));
    close gcf;
end