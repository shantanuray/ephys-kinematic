function plot_computed(trial_list, dataLabel, bodyPart, title_str, fsKinematic, fsEphys, alignBy, annotateON, show_fig, save_fig, save_loc)
% Plots velocity/acceleration data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_computed(trial_list, dataLabel, bodyPart, ...
%                      titlestr,...
%                      fsKinematic, fsEphys,...
%                      alignBy, annotateON,...
%                      showfig, savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabel: (str) Data label for velocity or acceleration
%                 eg. 'anipose_fixed_relative_velocity' or
%                     'anipose_first_sc_relative_velocity' or
%                     'anipose_first_sc_relative_acceleration'
%   - bodyPart: (str) string with data label name or index position
%                 eg. 'left_wrist_x' or 'right_d2_knuckle_r'
%   - fsKinematic: (float) Sampling frequency for kinematic data (Default: 200 Hz)
%   - fsEphys : (float) Sampling frequency for ephys data (Default: 30000 Hz)
%   - titlestr  : Append to file name (Default: '')
%   - alignBy: (str) Align plots of all trials by a reference:
%              - 'refMax' (default): Maximum velocity/acceleration
%              - '% reach': align entire reach into 100 samples and plot as % reach (use with first_sc)
%   - annotateON: If true, mark when light ON (Default: true)
%   - showfig: (logical) true to show figure automatically (Default: true)
%   - savefig: (logical) true to save figure automatically (Default: false)
%   - saveloc: (str) if savefig is true, where to save the figures
%
% Example: plot_computed(trial_list, 'aniposeData_fixed_relative_velocity', 'right_d2_knuckle_xyzSpeed',...
%                        'AT_A19-1_2021-09-01_12-15-40_hfwr_manual_16mW_video',...
%                        200, 30000,...
%                        'refMax', true, ...
%                        false, true, '/Users/chico/Desktop');

%% Note: Plot as 3-D to encapsulate the trial number as 3rd coordinate for ease of review


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

plot_label = dataLabel;
% Plot data vs t   
f = figure('color', [1 1 1], 'visible', 'off');
if contains(lower(plot_label), 'velocity')
    n = 1;
    ylabel ('Velocity','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    if strcmpi(alignBy, 'refMax')
        plot_str = sprintf('%s Velocity-Time Plot %s', title_str, bodyPart);
    elseif strcmpi(alignBy, '% reach')
        plot_str = sprintf('%s Velocity-Pct Reach Plot %s', title_str, bodyPart);
    end
elseif contains(lower(plot_label), 'acceleration')
    n = 2;
    ylabel ('Acceleration','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    if strcmpi(alignBy, 'refMax')
        plot_str = sprintf('%s Acceleration-Time Plot %s %s', title_str, bodyPart);
    elseif strcmpi(alignBy, '% reach')
        plot_str = sprintf('%s Acceleration-Pct Reach Plot %s %s', title_str, bodyPart);
    end
else
    n = 0;
    if strcmpi(alignBy, 'refMax')
        plot_str = sprintf('%s %s vs Time %s %s', title_str, plot_label, bodyPart);
    elseif strcmpi(alignBy, '% reach')
        plot_str = sprintf('%s %s Pct Reach %s %s', title_str, plot_label, bodyPart);
    else
        plot_str = sprintf('%s %s %s', title_str, plot_label, bodyPart);
    end
end
%grid on;
hold on;
%grid on;
xlabel('time (sec)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
set (gca, 'FontName', 'Arial', 'FontSize', 12, 'linewidth', 1);

% Loop over every trial
for trial_idx=1:length(trial_list)
    % Check if data is present
    plot_data = [];
    if ~isempty(find(strcmpi(plot_label, fieldnames(trial_list(trial_idx)))))
        if ~isempty(find(strcmpi(bodyPart,trial_list(trial_idx).(plot_label).Properties.VariableNames)))
            plot_data = trial_list(trial_idx).(plot_label).(bodyPart);
        end
    end
    if ~isempty(plot_data)
        num_frames = length(plot_data); 
        t = 1:num_frames;
        if strcmpi(alignBy, 'refMax')
            max_velocity = max(plot_data);
            max_loc = find(plot_data == max_velocity);
            t = t - max_loc;
            t = t/fsKinematic; %time base
        elseif strcmpi(alignBy, '% reach')
            data_interp = interp1(1:length(plot_data),plot_data,1:100);
            plot_data = data_interp';
            t = 1:100; % Percentage reach
        else
            t = t/fsKinematic; %time base
        end
        
        if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
            plot3(t, plot_data, ones(1, length(plot_data))*trial_idx, 'g');
            % text(t(1), plot_data(1), strcat('\leftarrow ', string(trial_idx)), 'Color','red','FontSize',10)
            if annotateON
                lightOn_start_ts_trial = trial_list(trial_idx).lightOnTrig_ts(1) -...
                                         trial_list(trial_idx).start_ts +...
                                         1 - n;
                anipose_lightOn_idx = ceil(lightOn_start_ts_trial*fsKinematic/fsEphys);
                trial_dur = ceil((trial_list(trial_idx).end_ts_first-trial_list(trial_idx).start_ts+1-n)*1000/fsEphys);;
                if anipose_lightOn_idx == 0
                    anipose_lightOn_idx = 1;
                end
                disp(sprintf('Trial #%d: light on after %d samples / %dms from start of trial; Total dur = %dms', trial_idx, anipose_lightOn_idx, ceil(anipose_lightOn_idx*1000/fsKinematic), trial_dur))
                if anipose_lightOn_idx <= length(plot_data)
                    plot3(t(anipose_lightOn_idx), plot_data(anipose_lightOn_idx), trial_idx, 'yo',...
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
    saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.fig')), 'fig');
    saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
end