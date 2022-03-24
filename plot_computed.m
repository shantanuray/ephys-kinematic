function plot_computed(trial_list, dataLabels, bodyPart, fs, title_str, ref2max, annotateON, show_fig, save_fig, save_loc)
% Plots velocity/acceleration data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_computed(trial_list, dataLabels, bodyPart, ...
%                      fs, ...
%                      titlestr, ref2max,annotateON,...
%                      showfig, savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed_relative_velocity'} or
%                     {'anipose_fixed_relative_velocity', 'anipose_first_sc_relative_velocity'}
%   - bodyPart: string with data label name or index position
%                 eg. 'left_wrist_x' or 'right_d2_knuckle_r'
%   - fs        : Sampling frequency
%   - titlestr  : Append to file name
%   - ref2max: If true, normalize distance (v v/s d plot) wrt to distance at max velocity (Default: true)
%   - annotateON: If true, mark when light ON (default: true)
%   - showfig: true to show figure automatically (Default: true)
%   - savefig: true to save figure automatically (Default: false)
%   - saveloc: if savefig is true, where to save the figures
%
% Example: plot_computed(trial_list, {'anipose_fixed_relative_velocity'}, 'right_d2_knuckle_r',...
%                        200,...
%                        'AT_A19-1_2021-09-01_12-15-40_hfwr_manual_16mW_video',...
%                        true, false, ...
%                        true, '/Users/chico/Desktop');


if nargin<5
    title_str = '';
end

if nargin < 6
    ref2max = true;
end

if nargin<7
    annotateON = true;
end

if nargin<8
    show_fig = true;
end

if nargin<9
    save_fig = false;
end

if save_fig & nargin<10
    save_loc = uigetdir();
end

for dataLabel_idx = 1:length(dataLabels)
    plot_label = dataLabels{dataLabel_idx};
    % Plot data vs t   
    f = figure('color', [1 1 1], 'visible', 'off');
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Velocity-Time Plot %s %s', title_str, plot_label, bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Acceleration-Time Plot %s %s', title_str, plot_label, bodyPart);
    else
        n = 0;
        plot_str = sprintf('%s Time %s %s', title_str, plot_label, bodyPart);
    end
    hold on;
    %grid on;
    xlabel('time (sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
    
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
                plot(t, plot_data, 'g');
                if annotateON
                    lightOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                    plot(t(lightOn_idx), plot_data(lightOn_idx),'mo',...
                        'MarkerEdgeColor','m',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            else
                plot(t, plot_data, 'k');
            end
        end
    end
    hold off
    if show_fig
        set(f, 'visible', 'on')
    end
    if save_fig
        saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
        close gcf;
    end
end


for dataLabel_idx = 1:length(dataLabels)
    plot_label = dataLabels{dataLabel_idx};
    % Plot data vs distance
    f = figure('color', [1 1 1], 'visible', 'off');
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Velocity-Distance Plot %s %s', title_str, plot_label, bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Acceleration-Distance Plot %s %s', title_str, plot_label, bodyPart);
    else
        n = 0;
        plot_str = sprintf('%s Distance %s %s', title_str, plot_label, bodyPart);
    end
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
                plot(dist_data, plot_data, 'g');
                if annotateON
                    lightOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                    plot(dist_data(lightOn_idx), plot_data(lightOn_idx), 'mo',...
                        'MarkerEdgeColor','m',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            else
                plot(dist_data, plot_data, 'k');
            end
        end
    end
    hold off
    if show_fig
        set(f, 'visible', 'on')
    end
    if save_fig
        saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
        close gcf;
    end
end
