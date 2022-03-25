function [mean_data_ON, mean_data_OFF] = plot_computed_mean(trial_list, dataLabels, bodyPart, fs, title_str, alignBy, annotateON, show_fig, save_fig, save_loc)
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
%   - alignBy: Align plots of all trials by a reference:
%              - start (default): start of reach
%              - max - align by the max (such as max velocity)
%              - spout_contact - align by the first spout contact
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
    alignBy = 'start';
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
        ylabel ('Average Velocity (mm/sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Average Velocity-Time Plot %s %s', title_str, plot_label, bodyPart);
    elseif contains(lower(plot_label), 'acceleration')
        n = 2;
        ylabel ('Average Acceleration (mm/sec^2)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
        plot_str = sprintf('%s Average Acceleration-Time Plot %s %s', title_str, plot_label, bodyPart);
    else
        n = 0;
        plot_str = sprintf('%s Time %s %s', title_str, plot_label, bodyPart);
    end
    %grid on;
    xlabel('time (sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);
    
    % Loop over every trial
    mean_data_ON = [];
    spoutContact_ON = [];
    count_ON = 0;
    mean_data_OFF = [];
    spoutContact_OFF = [];
    count_OFF = 0;

    for trial_idx=1:length(trial_list)
        plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
        if ~isempty(plot_data)
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                count_ON = count_ON + 1;
                mean_data_ON = [mean_data_ON, abs(plot_data)];
                spoutContact_ON = [spoutContact_ON;...
                                    trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx];
            else
                count_OFF = count_OFF + 1;
                mean_data_OFF = [mean_data_OFF, abs(plot_data)];
                spoutContact_OFF = [spoutContact_OFF;...
                                    trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx]; 
            end
        end
    end
    mean_data_ON = sum(mean_data_ON, 2)/size(mean_data_ON, 2);
    t = 1:length(mean_data_ON);
    t = t/fs;
    plot(t, mean_data_ON, 'g');
    hold on
    mean_data_OFF = sum(mean_data_OFF, 2)/size(mean_data_OFF, 2);
    t = 1:length(mean_data_OFF);
    t = t/fs;
    plot(t, mean_data_OFF, 'k');
    if show_fig
        set(f, 'visible', 'on')
    end
    if save_fig
        saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
        close gcf;
    end
end
