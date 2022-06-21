root_dir = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/2022-06-20';
refLabel = 'waterSpout';
ref2max = true;
fsKinematic = 200;
fsEphys = 30000;
annotateON = true;
show_fig = false;
save_fig = true;
save_loc = root_dir;
summary_file = strcat('summarytable_', datestr(now,'yyyy-mm-dd'));

% mat_list = {'/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/AT_A1-2_2021-09-08_14-01-05_hfwr_manualLightOn_090821_212pm.mat', 
% '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/AT_A19-1_2021-09-01_12-15-40_hfwr_manual_16mW.mat', 
% '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/AT_A19-1_2021-09-02_15-56-44_hfwr_auto_16mW_090221_408P.mat', 
% '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/AT_A19-2_2021-09-10_14-18-39_hfwr_auto_lighton_noisy_091021_218pm.mat', 
% '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/AT_auto_manual_LightON_2021-09-24_16-29-56.mat', 
% '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/AT_manualAuto_LightON_2021-09-27_14-10-00.mat'};
mat_list = dir(fullfile(root_dir, 'A*.mat'));
summaryTable = table();
for mat_indx = 1:length(mat_list)
    % mat_file = mat_list{mat_indx};
    mat_file = fullfile(mat_list(mat_indx).folder, mat_list(mat_indx).name);
    [fpath, title_str, ext] = fileparts(mat_file);
    trial_list = [];
    disp(sprintf('Loading %s', mat_file));
    load(mat_file, 'trial_list');
    disp(sprintf('Getting summary info for %d trials', length(trial_list)));
    try
        summaryTrial = getSummaryInfo(trial_list, fsKinematic, title_str, 'right_d2_knuckle', 'aniposeData_first_sc');
        summaryTable = [summaryTable; summaryTrial];
    catch
        disp(sprintf('Issue with %s', title_str));
    end
end
save(fullfile(save_loc, summary_file), 'summaryTable');