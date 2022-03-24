function plot_3Ddata(trial_list, dataLabels, bodyPart, title_str, refLabel, annotateON, show_fig, save_fig, save_loc)
% Plots 3D data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_3Ddata(trial_list, dataLabels, bodyPart, ...
%                      fs, ...
%                      annotateON,...
%                      savefig, saveloc);
%
% Parameters:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed_relative_velocity'} or
%                     {'anipose_fixed_relative_velocity', 'anipose_first_sc_relative_velocity'}
%   - bodyPart: string with data label name or index position
%                 eg. 'left_wrist' or 'right_d2_knuckle'
%   - refLabel: string with ref label (default: 'waterSpout')
%   - annotateON: If true, mark when light ON (default: true)
%   - savefig: true to save figure automatically (Default: false)
%   - saveloc: if savefig is true, where to save the figures
%
% Example: plot_3Ddata(trial_list, {'anipose_first_sc'}, 'right_d2_knuckle',...
%                        200, true, ...
%                        true, '/Users/chico/Desktop');

if nargin<4
    title_str='';
end

if nargin < 5
    refLabel = 'waterSpout';
end

if nargin<6
    annotateON = true;
end

if nargin<7
    show_fig = true;
end

if nargin<8
    save_fig = false;
end

if save_fig & nargin<9
    save_loc = uigetdir();
end

for dataLabel_idx = 1:length(dataLabels)
    % Plot XYZ over time
    plot_str = strcat(title_str, ' ', bodyPart, ' 3D');
    f = figure('color', [1 1 1], 'visible', 'off');
    xlabel ('x (mm)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    ylabel ('y (mm)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    zlabel ('z (mm)','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    % view([-37 -18]);
    %set (gca, 'linewidth', 2);
    plot_label = dataLabels{dataLabel_idx};
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
    % Loop over every trial
    for trial_idx=1:length(trial_list)
        dataTable = trial_list(trial_idx).(plot_label);
        data = table2array(dataTable);
        plot_data = data(:, bodyPartLocation);
        if ~isempty(plot_data)
            if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                % Plot x axis corresponds to x coordinate in anipose
                % Plot y axis corresponds to z coordinate in anipose
                % Plot z axis corresponds to -y coordinate in anipose
                plot3(plot_data(:, 1),plot_data(:,3),-plot_data(:,2), 'g');
                if annotateON
                    lightOn_idx = trial_list(trial_idx).end_idx_first - trial_list(trial_idx).start_idx + 1 - n;
                    % Plot x axis corresponds to x coordinate in anipose
                    % Plot y axis corresponds to z coordinate in anipose
                    % Plot z axis corresponds to -y coordinate in anipose
                    plot3(plot_data(lightOn_idx, 1),plot_data(lightOn_idx, 3),-plot_data(lightOn_idx, 2), 'mo',...
                        'MarkerEdgeColor','m',...
                       'MarkerFaceColor','m',...
                       'MarkerSize',5);
                end
            else
                % Plot x axis corresponds to x coordinate in anipose
                % Plot y axis corresponds to z coordinate in anipose
                % Plot z axis corresponds to -y coordinate in anipose
                plot3(plot_data(:, 1),plot_data(:,3),-plot_data(:,2), 'k');
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