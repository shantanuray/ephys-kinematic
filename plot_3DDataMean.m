function [ON_trial_dataMean,...
          OFF_trial_dataMean,...
          anipose_lightOn_idx,...
          spoutOn_idx] = plot_3DDataMean(trial_list, dataLabel, bodyPart, fsKinematic, fsEphys, title_str, refLabel, annotateON, show_fig, save_fig, save_loc)
% Plots mean of 3D data for reach trial
% Assumption: Data has been precalculated; Missing data will be padded with NaN
%
% Usage: plot_3DDataMean(trial_list, dataLabel, bodyPart, ...
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
%   - fsKinematic, fsEphys: (float) Smapling frequence for kinematic and ephys data resp.
%   - title_str: (str) Used in labeling plot and saving plot
%   - refLabel: (str) string with ref label (default: 'waterSpout')
%   - annotateON: (logical) If true, mark when light ON (default: true)
%   - savefig: (logical) true to save figure automatically (Default: false)
%   - saveloc: (str) if savefig is true, where to save the figures
%
% Example: plot_3DDataMean(trial_list, 'aniposeData_first_sc_relative', 'right_d2_knuckle',200, 30000,...
%                        'AT_A19-2',...
%                        'waterSpout',...
%                        true, ...
%                        false, true, '/Users/chico/Desktop');
%          plot_3DDataMean(trial_list, 'aniposeData_first_sc_relative', 'right_d2_knuckle', 200, 300, 'AT_A19-2', 'waterSpout', true, true);

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

% Plot mean of XYZ over time
plot_str = strcat(title_str, ' ', bodyPart, ' 3D');
f = figure('color', [1 1 1], 'visible', 'off');
xlabel ('x','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
ylabel ('y','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
zlabel ('z','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
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
    dataref = data(1, refLocation);
    % Plot x axis corresponds to x coordinate in anipose
    % Plot y axis corresponds to z coordinate in anipose
    % Plot z axis corresponds to -y coordinate in anipose
    % Plot firs spout position
    plot3(dataref(1, 1),dataref(1,3),-dataref(1,2), 'ks',...
                    'MarkerEdgeColor','k',...
                   'MarkerFaceColor','k',...
                   'MarkerSize',5);
    hold on;
end
ON_trial_dataMean = [];
OFF_trial_dataMean = [];
anipose_lightOn_idx = [];
spoutOn_idx = [];

% Get reach from each trial and prepare data for mean
for trial_idx=1:length(trial_list)
    dataTable = trial_list(trial_idx).(plot_label);
    if istable(dataTable)
        data = table2array(dataTable);
        if ~isempty(data)
            trial_data = data(:, bodyPartLocation);
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                if size(trial_data, 1) < size(ON_trial_dataMean, 1)
                    trial_data = cat(1, nan(size(ON_trial_dataMean, 1)-size(trial_data, 1), 3),...
                                        trial_data);
                end
                if size(trial_data, 1) > size(ON_trial_dataMean,1)
                    ON_trial_dataMean = cat(1, nan(size(trial_data,1)-size(ON_trial_dataMean,1), 3),...
                                        ON_trial_dataMean);
                end
                ON_trial_dataMean = mean(cat(3, ON_trial_dataMean, trial_data), 3, 'omitnan');
                if annotateON
                    lightOn_start_ts_trial = trial_list(trial_idx).lightOnTrig_ts(1) -...
                                             trial_list(trial_idx).start_ts +...
                                             1 - n;
                    anipose_lightOn_idx = [anipose_lightOn_idx; ceil(lightOn_start_ts_trial*fsKinematic/fsEphys)];
                    if anipose_lightOn_idx(end) == 0
                        anipose_lightOn_idx(end) = 1;
                    end
                end
            else
                if size(trial_data, 1) < size(OFF_trial_dataMean, 1)
                    trial_data = cat(1, nan(size(OFF_trial_dataMean, 1)-size(trial_data, 1), 3),...
                                        trial_data);
                end
                if size(trial_data, 1) > size(OFF_trial_dataMean,1)
                    OFF_trial_dataMean = cat(1, nan(size(trial_data,1)-size(OFF_trial_dataMean,1), 3),...
                                        OFF_trial_dataMean);
                end
                OFF_trial_dataMean = mean(cat(3, OFF_trial_dataMean, trial_data), 3, 'omitnan');
            end
            if annotateON
                spoutOn_idx = [spoutOn_idx;trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n];
            end
        end
    else
        disp(sprintf('Issue processing trial # %d in %s. Skipping', trial_idx, title_str))
    end
end
% Calculate the mean
anipose_lightOn_idxMean = mean(anipose_lightOn_idx, 1, 'omitnan');
spoutOn_idxMean = mean(spoutOn_idx, 1, 'omitnan');
if ~isempty(ON_trial_dataMean)
    plot3(ON_trial_dataMean(:, 1),ON_trial_dataMean(:,3),-ON_trial_dataMean(:,2), 'b');
end
hold on
% if (anipose_lightOn_idxMean <= length(ON_trial_dataMean)) & (length(anipose_lightOn_idxMean)>0)
%     anipose_lightOn_idxMean = round(anipose_lightOn_idxMean, 0);
%     plot3(ON_trial_dataMean(anipose_lightOn_idxMean, 1),...
%           ON_trial_dataMean(anipose_lightOn_idxMean, 3),...
%           -ON_trial_dataMean(anipose_lightOn_idxMean, 2), 'yo',...
%           'MarkerEdgeColor',[0,0.5,0],...
%           'MarkerFaceColor',[0,0.5,0],...
%           'MarkerSize',10);
% end
if ~isempty(OFF_trial_dataMean)
    plot3(OFF_trial_dataMean(:, 1),OFF_trial_dataMean(:,3),-OFF_trial_dataMean(:,2), 'k');
end
% if (spoutOn_idxMean <= length(OFF_trial_dataMean)) & (length(spoutOn_idxMean)>0)
%     spoutOn_idxMean = round(spoutOn_idxMean, 0);
%     plot3(OFF_trial_dataMean(spoutOn_idxMean, 1),...
%         OFF_trial_dataMean(spoutOn_idxMean, 3),...
%         -OFF_trial_dataMean(spoutOn_idxMean, 2), 'mo',...
%         'MarkerEdgeColor',[0.49,0.18,0.56],...
%        'MarkerFaceColor',[0.49,0.18,0.56],...
%        'MarkerSize',5);
% end
hold off
if show_fig
    set(f, 'visible', 'on')
end
if save_fig
    saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.png')));
    saveas(gcf,fullfile(save_loc, strcat(replace(plot_str, ' ', '_'), '.fig')), 'fig');
end
