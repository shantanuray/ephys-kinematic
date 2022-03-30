function plot_computed(trial_list, dataLabels, bodyPart, title_str, fsKinematic, fsEphsys, refMax, annotateON, show_fig, save_fig, save_loc)
% Plots velocity/acceleration data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_computed(trial_list, dataLabels, bodyPart, ...
%                      titlestr,...
%                      fsKinematic, fsEphsys,...
%                      refMax, annotateON,...
%                      showfig, savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed_relative_velocity'} or
%                     {'anipose_fixed_relative_velocity', 'anipose_first_sc_relative_velocity'}
%   - bodyPart: string with data label name or index position
%                 eg. 'left_wrist_x' or 'right_d2_knuckle_r'
%   - fsKinematic : Sampling frequency for kinematic data (Default: 200 Hz)
%   - fsEphsys : Sampling frequency for ephys data (Default: 30000 Hz)
%   - titlestr  : Append to file name (Default: '')
%   - refMax: If true, normalize distance (v v/s d plot) wrt to distance at max velocity (Default: true)
%   - annotateON: If true, mark when light ON (Default: true)
%   - showfig: true to show figure automatically (Default: true)
%   - savefig: true to save figure automatically (Default: false)
%   - saveloc: if savefig is true, where to save the figures
%
% Example: plot_computed(trial_list, {'aniposeData_fixed_relative_velocity'}, 'right_d2_knuckle_r',...
%                        'AT_A19-1_2021-09-01_12-15-40_hfwr_manual_16mW_video',...
%                        200, 30000,...
%                        true, true, ...
%                        false, true, '/Users/chico/Desktop');

% Note: Plot as 3-D to encapsulate the trial number as 3rd coordinate for ease of review


if nargin<4
    title_str = '';
end
if nargin<5
    fsKinematic = 200;
end
if nargin<6
    fsEphsys = 30000;
end

if nargin < 7
    refMax = true;
end

if nargin<8
    annotateON = true;
end

if nargin<9
    show_fig = true;
end

if nargin<10
    save_fig = false;
end

if save_fig & nargin<11
    save_loc = uigetdir();
end

for dataLabel_idx = 1:length(dataLabels)
    plot_label = dataLabels{dataLabel_idx};
    % Plot data vs t   
    f = figure('color', [1 1 1], 'visible', 'off');
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Velocity-Time Plot %s %s', title_str, bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Acceleration-Time Plot %s %s', title_str, bodyPart);
    else
        n = 0;
        plot_str = sprintf('%s %s Time %s', title_str, plot_label, bodyPart);
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
            if refMax
               max_velocity = max(plot_data);
               max_loc = find(plot_data == max_velocity);
               t = t - max_loc;
            end
            t = t/fsKinematic; %time base
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                plot3(t, plot_data, ones(1, length(plot_data))*trial_idx, 'g');
                % text(t(1), plot_data(1), strcat('\leftarrow ', string(trial_idx)), 'Color','red','FontSize',10)
                if annotateON
                    lightOn_idx = ceil((trial_list(trial_idx).lightOnTrig_ts(1) -...
                                   trial_list(trial_idx).start_ts)*fsKinematic/fsEphsys) + 1 - n;
                    disp(sprintf('#%d: light on %d', trial_idx, lightOn_idx))
                    if lightOn_idx <= length(plot_data)
                        plot3(t(lightOn_idx), plot_data(lightOn_idx), trial_idx, 'yo',...
                            'MarkerEdgeColor','y',...
                           'MarkerFaceColor','y',...
                           'MarkerSize',5);
                    end
                end
            else
                plot3(t, plot_data, ones(1, length(plot_data))*trial_idx, 'k');
            end
            if annotateON
                spoutOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                if spoutOn_idx <= length(plot_data)
                    plot3(t(spoutOn_idx), plot_data(spoutOn_idx),trial_idx, 'mo',...
                        'MarkerEdgeColor','m',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            end
        end
    end
    hold off
    if show_fig
        set(f, 'visible', 'on')
    end
    if save_fig
        saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.fig')));
    end
end


for dataLabel_idx = 1:length(dataLabels)
    plot_label = dataLabels{dataLabel_idx};
    % Plot data vs distance
    f = figure('color', [1 1 1], 'visible', 'off');
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Velocity-Distance Plot %s %s', title_str, bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Acceleration-Distance Plot %s %s', title_str, bodyPart);
    else
        n = 0;
        plot_str = sprintf('%s %s Distance %s', title_str, plot_label, bodyPart);
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
            if refMax
                max_velocity = max(plot_data);
                max_loc = find(plot_data == max_velocity);
                dist_at_max_vel = dist_data(max_loc);
                dist_data = dist_data - dist_at_max_vel;
            end
       
            if ~isempty(dist_data)
                dist_data(end)= [];
            end
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                plot3(dist_data, plot_data, ones(1, length(plot_data))*trial_idx, 'g');
                if annotateON
                    lightOn_idx = ceil((trial_list(trial_idx).lightOnTrig_ts(1) -...
                                   trial_list(trial_idx).start_ts)*fsKinematic/fsEphsys) + 1 - n;
                    disp(sprintf('#%d: light on %d', trial_idx, lightOn_idx))
                    if lightOn_idx <= length(plot_data)
                        plot3(dist_data(lightOn_idx), plot_data(lightOn_idx), trial_idx, 'yo',...
                            'MarkerEdgeColor','y',...
                           'MarkerFaceColor','y',...
                           'MarkerSize',5);
                    end
                end
            else
                plot3(dist_data, plot_data, ones(1, length(plot_data))*trial_idx, 'k');
            end
            if annotateON
                spoutOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                if spoutOn_idx <= length(plot_data)
                    plot3(dist_data(spoutOn_idx), plot_data(spoutOn_idx),trial_idx, 'mo',...
                        'MarkerEdgeColor','m',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            end
        end
    end
    hold off
    if show_fig
        set(f, 'visible', 'on')
    end
    if save_fig
        saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.fig')));
    end
end