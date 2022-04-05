function plot_3Ddata(trial_list, dataLabels, bodyPart, fsKinematic, fsEphys, title_str, refLabel, annotateON, show_fig, save_fig, save_loc)
% Plots 3D data for reach trial for given reach data labels
% Assumption: Data has been precalculated
%
% Usage: plot_3Ddata(trial_list, dataLabels, bodyPart, ...
%                      fsKinematic, fsEphys, ...
%                      titleStr,...
%                      refLabel,...
%                      annotateON,...
%                      showFig, savefig, saveloc);
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
% Example: plot_3Ddata(trial_list, {'anipose_fixed_sc'}, 'right_d2_knuckle',200, 30000,...
%                        'AT_A19-2',...
%                        'waterSpout',...
%                        true, ...
%                        false, true, '/Users/chico/Desktop');
%          plot_3Ddata(trial_list, {'aniposeData_first_sc'}, 'right_d2_knuckle', 200, 300, 'AT_A19-2', 'waterSpout', true, true);

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

for dataLabel_idx = 1:length(dataLabels)
    % Plot XYZ over time
    plot_str = strcat(title_str, ' ', bodyPart, ' 3D');
    f = figure('color', [1 1 1], 'visible', 'off');
    xlabel ('x','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    ylabel ('y','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
    zlabel ('z','FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Arial');
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
        if istable(dataTable)
            data = table2array(dataTable);
            plot_data = data(:, bodyPartLocation);
            if ~isempty(plot_data)
                if strcmpi(trial_list(trial_idx).lightTrig, 'ON')
                    plot3(plot_data(:, 1),plot_data(:,3),-plot_data(:,2), 'b');
                    % text(t(1), plot_data(1), strcat('\leftarrow ', string(trial_idx)), 'Color','red','FontSize',10)
                    if annotateON
                        lightOn_idx = ceil((trial_list(trial_idx).lightOnTrig_ts(1) -...
                                       trial_list(trial_idx).start_ts)*fsKinematic/fsEphys) + 1 - n;
                        disp(sprintf('#%d: light on %d', trial_idx, lightOn_idx))
                        if lightOn_idx <= length(plot_data)
                            plot3(plot_data(lightOn_idx, 1),plot_data(lightOn_idx, 3),-plot_data(lightOn_idx, 2), 'yo',...
                                  'MarkerEdgeColor',[0,0.5,0],...
                                  'MarkerFaceColor',[0,0.5,0],...
                                  'MarkerSize',10);
                        end
                    end
                else
                    plot3(plot_data(:, 1),plot_data(:,3),-plot_data(:,2), 'k');
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
end