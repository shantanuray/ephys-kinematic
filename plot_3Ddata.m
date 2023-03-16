function plot_3Ddata(trial_list, dataLabel, bodyPart, fsKinematic, fsEphys, title_str, refLabel, annotateON, show_fig, save_fig, save_loc)
% Plots 3D data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_3Ddata(trial_list, dataLabel, bodyPart, ...
%                      fsKinematic, fsEphys, ...
%                      titleStr,...
%                      refLabel,...
%                      annotateON,...
%                      showFig, savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabel: (str) Data label for 3D plot
%                 eg. 'anipose_fixed' - Fixed time interbal
%                     'aniposeData_first_sc' - First spout contact
%                     'aniposeData_last_sc'  - Last spout contact
%   - bodyPart: (str) string with data label name or index position
%                 eg. 'left_wrist' or 'right_d2_knuckle'
%   - fsKinematic, fsEphys: (float) Sampling frequence for kinematic and ephys data resp.
%   - title_str: (str) Used in labeling plot and saving plot, use the name of the mat file 
%   - refLabel: (str) string with ref label (default: 'waterSpout')
%   - annotateON: (logical) If true, mark when light ON (default: true)
%   - savefig: (logical) true to save figure automatically (Default: false)
%   - saveloc: (str) if savefig is true, where to save the figures
%
% Example: 
% trial_list=trialList_solenoid_on;
% plot_3Ddata(trial_list(10),'aniposeData_first_sc', 'right_d3_knuckle',200, 30000,'namae of matfile',...
%                       'waterSpout',...
%                        true,...
%                        true,...
%                        true);
% plot_3Ddata(trial_list,'aniposeData_fixed_relative', 'right_d2_knuckle', 200, 30000, 'A15-2', 'waterSpout', true, true);

if nargin<6
    title_str='';
end

if nargin < 7
    refLabel = 'waterSpout';
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

% Plot XYZ over time
plot_str = strcat(title_str, ' ', bodyPart, ' 3D');
f = figure('color', [1 1 1], 'visible', 'off');
xlabel ('x','FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');
ylabel ('y','FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');
zlabel ('z','FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial');
% view([-37 -18]);
%set (gca, 'linewidth', 2);
plot_label = dataLabel;
if contains(lower(plot_label), 'velocity')
    n = 1;
elseif contains(lower(plot_label), 'acceleration')
    n = 2;
else
    n = 0;
end

dataTable = trial_list(1).(plot_label);
data = table2array(dataTable);
colNames = dataTable.Properties.VariableNames;
bodyPartLocation = strfind(colNames, bodyPart);
bodyPartLocation = find(~cellfun(@isempty,bodyPartLocation));
bodyPartLocation = bodyPartLocation(1:3);  % x,y,z only
if ~isempty(refLabel)
    refLocation = strfind(colNames, refLabel);
    refLocation = find(~cellfun(@isempty,refLocation));
    refLocation = refLocation(1:3);  % x,y,z only
    %mean?
    dataref = data(1, refLocation);
    % Plot x axis corresponds to x coordinate in anipose
    % Plot y axis corresponds to z coordinate in anipose
    % Plot z axis corresponds to -y coordinate in anipose
    % Plot firs spout position
    plot3(dataref(1, 1),dataref(1,3),-dataref(1,2), 'x',...
                    'MarkerEdgeColor','k',...
                   'MarkerFaceColor','k',...
                   'MarkerSize',7.5);
    hold on;
end
% Loop over every trial
for trial_idx=1:length(trial_list)
    dataTable = trial_list(trial_idx).(plot_label);
    if istable(dataTable)
        data = table2array(dataTable);
        plot_data = data(:, bodyPartLocation);
        if ~isempty(plot_data)
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                plot3(plot_data(:, 1),plot_data(:,3),-plot_data(:,2), 'b','LineWidth',1.5);
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
                        plot3(plot_data(anipose_lightOn_idx, 1),plot_data(anipose_lightOn_idx, 3),-plot_data(anipose_lightOn_idx, 2), 'yo',...
                              'MarkerEdgeColor',[0,0.5,0],...
                              'MarkerFaceColor',[0,0.5,0],...
                              'MarkerSize',7.5);
                    end
                end
            else
                plot3(plot_data(:, 1),plot_data(:,3),-plot_data(:,2), 'k','LineWidth',1.5);
            end
            if annotateON
                spoutOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                if spoutOn_idx <= length(plot_data)
                    plot3(plot_data(spoutOn_idx, 1), plot_data(spoutOn_idx, 3), -plot_data(spoutOn_idx, 2), 'mo',...
                        'MarkerEdgeColor',[0.49,0.18,0.56],...
                       'MarkerFaceColor',[0.49,0.18,0.56],...
                       'MarkerSize',5);
                end
                % textpos = ceil(length(plot_data)/2);
                % text(plot_data(textpos,1), plot_data(textpos,3), -plot_data(textpos,2), strcat('\leftarrow ', string(trial_idx)), 'Color', 'red', 'FontSize', 8);
            end
        end
    else
        disp(sprintf('Issue processing trial # %d in %s. Skipping', trial_idx, title_str))
    end
end
hold off
if show_fig
    set(f, 'visible', 'on')
end
if save_fig
    saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
    saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.fig')), 'fig');
end
