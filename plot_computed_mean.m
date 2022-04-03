function [spoutContact_ON, spoutContact_OFF, lightON] = plot_computed_mean(trial_list, dataLabels, bodyPart, title_str, fsKinematic, fsEphys, alignBy, annotateON, show_fig, save_fig, save_loc)
% Plots velocity/acceleration data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_computed_mean(trial_list, dataLabels, bodyPart, ...
%                      titlestr,...
%                      fsKinematic, fsEphys, ...
%                      ref2max,annotateON,...
%                      showfig, savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed_relative_velocity'} or
%                     {'anipose_fixed_relative_velocity', 'anipose_first_sc_relative_velocity'}
%   - bodyPart: string with data label name or index position
%                 eg. 'left_wrist_x' or 'right_d2_knuckle_r'
%   - titlestr  : Append to file name (Default: '')
%   - fsKinematic : Sampling frequency for kinematic (anipose) data (Default: 200 Hz)
%   - fsEphys   : Sampling frequency for kinematic (ephys) data (Default: 30000 Hz)
%   - alignBy: Align plots of all trials by a reference:
%              - refMax (default): Maximum velocity/acceleration
%              - % reach: align entire reach into 100 samples and plot as % reach (use with first_sc)
%   - annotateON: If true, mark when light ON (default: true)
%   - showfig: true to show figure automatically (Default: true)
%   - savefig: true to save figure automatically (Default: false)
%   - saveloc: if savefig is true, where to save the figures
%
% Example: plot_computed_mean(trial_list, {'anipose_fixed_relative_velocity'}, 'right_d2_knuckle_xyzSpeed',...
%                        'AT_A19-1_2021-09-01_12-15-40_hfwr_manual_16mW_video',...
%                        200,30000,...
%                        true, true, ...
%                        false, true, '/Users/chico/Desktop');


if nargin<4
    title_str = '';
end
if nargin<5
    fsKinematic = 200;
end
if nargin<6
    fsEphys = 30000;
end
if nargin < 7
    alignBy = 'refMax';
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
    f = figure('color', [1 1 1]);
    if contains(lower(plot_label), 'velocity')
        n = 1;
        ylabel ('Average Velocity','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        if strcmpi(alignBy, 'refMax')
            plot_str = sprintf('%s Average Velocity-Time Plot %s', title_str, bodyPart);
        elseif strcmpi(alignBy, '% reach')
            plot_str = sprintf('%s Average Velocity-Pct Reach Plot %s', title_str, bodyPart);
        end
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Average Acceleration','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        if strcmpi(alignBy, 'refMax')
            plot_str = sprintf('%s Average Acceleration-Time Plot %s %s', title_str, bodyPart);
        elseif strcmpi(alignBy, '% reach')
            plot_str = sprintf('%s Average Acceleration-Pct Reach Plot %s %s', title_str, bodyPart);
        end
    else
        n = 0;
        if strcmpi(alignBy, 'refMax')
            plot_str = sprintf('%s Average %s vs Time %s %s', title_str, plot_label, bodyPart);
        elseif strcmpi(alignBy, '% reach')
            plot_str = sprintf('%s Average %s Pct Reach %s %s', title_str, plot_label, bodyPart);
        else
            plot_str = sprintf('%s Average %s %s', title_str, plot_label, bodyPart);
        end
    end
    %grid on;
    if strcmpi(alignBy, 'refMax')
        xlabel('time (sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    elseif strcmpi(alignBy, '% reach')
        xlabel('% Reach','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    end
    set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
    
    % Loop over every trial
    data_ON = [];
    lightON = [];
    spoutContact_ON = [];
    count_ON = 0;
    data_OFF = [];
    spoutContact_OFF = [];
    count_OFF = 0;

    for trial_idx=1:length(trial_list)
        % Check if data is present
        plot_data = [];
        if ~isempty(find(strcmpi(plot_label, fieldnames(trial_list(trial_idx)))))
            if ~isempty(find(strcmpi(bodyPart,trial_list(trial_idx).(plot_label).Properties.VariableNames)))
                plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
            end
        end
        if ~isempty(plot_data)
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                count_ON = count_ON + 1;
                if strcmpi(alignBy, '% reach')
                    data_interp = interp1(1:length(plot_data),plot_data,1:100);
                    plot_data = data_interp';
                end
                data_ON = [data_ON, abs(plot_data)];
                lightON = [lightON, ceil((trial_list(trial_idx).lightOnTrig_ts(1) -...
                                   trial_list(trial_idx).start_ts)*fsKinematic/fsEphys) + 1 - n];
                spoutContact_ON = [spoutContact_ON;...
                                    trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx];
            else
                count_OFF = count_OFF + 1;
                if strcmpi(alignBy, '% reach')
                    data_interp = interp1(1:length(plot_data),plot_data,1:100);
                    plot_data = data_interp';
                end
                data_OFF = [data_OFF, abs(plot_data)];
                lightON = [lightON, nan];
                spoutContact_OFF = [spoutContact_OFF;...
                                    trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx]; 
            end
        end
    end
    data_ON_std = std(data_ON, 1, 2, 'omitnan');
    data_ON_mean = mean(data_ON, 2, 'omitnan');
    data_ON_mean_plus = data_ON_mean + data_ON_std;
    data_ON_mean_minus = data_ON_mean - data_ON_std;
    t_ON = 1:length(data_ON_mean);
    t_ON = t_ON/fsKinematic;
    t2_ON = [t_ON, fliplr(t_ON)];
    inBetween_ON = [data_ON_mean_plus', fliplr(data_ON_mean_minus')];
    data_OFF_std = std(data_OFF, 1, 2, 'omitnan');
    data_OFF_mean = mean(data_OFF, 2, 'omitnan');
    data_OFF_mean_plus = data_OFF_mean + data_OFF_std;
    data_OFF_mean_minus = data_OFF_mean - data_OFF_std;
    t_OFF = 1:length(data_OFF_mean);
    t_OFF = t_OFF/fsKinematic;
    t2_OFF = [t_OFF, fliplr(t_OFF)];
    inBetween_OFF = [data_OFF_mean_plus', fliplr(data_OFF_mean_minus')];
    patch(t2_OFF, inBetween_OFF, [221, 221, 221]/255, 'FaceAlpha',.5);
    hold on;
    patch(t2_ON, inBetween_ON, [209, 255, 197]/255, 'FaceAlpha',.3);
    plot(t_ON, data_ON_mean, 'g'); % Mean plot
    plot(t_ON, data_ON_mean_plus, 'Color', [200, 245, 190]/255); % Mean plot + std
    plot(t_ON, data_ON_mean_minus, 'Color', [200, 245, 190]/255); % Mean plot - std
    plot(t_OFF, data_OFF_mean, 'k'); % Mean plot
    plot(t_OFF, data_OFF_mean_plus, 'Color', [215, 215, 215]/255); % Mean plot + std
    plot(t_OFF, data_OFF_mean_minus, 'Color', [215, 215, 215]/255); % Mean plot - std
    hold off
    if show_fig
        set(f, 'visible', 'on')
    end
    if save_fig
        saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
    end
end
