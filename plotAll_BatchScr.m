root_dir = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/2022-04-12';
% root_dir = "C:\Users\shantanu.ray\Documents\MATLAB";
refLabel = 'waterSpout';
ref2max = true;
fsKinematic = 200;
fsEphys = 30000;
annotateON = true;
show_fig = false;
save_fig = true;
save_loc = root_dir;
alignBy = '% reach';

mat_list = dir(fullfile(root_dir, '*.mat'));
out = ;
for mat_indx = 1:length(mat_list)
    mat_file = fullfile(mat_list(mat_indx).folder, mat_list(mat_indx).name);
    [fpath, title_str, ext] = fileparts(mat_file);
    disp(title_str);
    trial_list = [];
    load(mat_file, 'trial_list');
    try
        plot_3Ddata(trial_list, 'aniposeData_first_sc', 'right_d2_knuckle', fsKinematic, fsEphys, strcat(title_str, '_first_sc_'), refLabel, annotateON, show_fig, save_fig, fullfile(save_loc, '3d'))
    catch
        disp(strcat('Error in processing', '- ', title_str))
    end
    try
        plot_3Ddata(trial_list, 'aniposeData_fixed', 'right_d2_knuckle', fsKinematic, fsEphys, strcat(title_str, '_fixed_'), refLabel, annotateON, show_fig, save_fig, fullfile(save_loc, '3d'))
    catch
        disp(strcat('Error in processing', '- ', title_str))
    end
    try
        plot_3Ddata(trial_list, 'aniposeData_last_sc', 'right_d2_knuckle', fsKinematic, fsEphys, strcat(title_str, '_last_sc_'), refLabel, annotateON, show_fig, save_fig, fullfile(save_loc, '3d'))
    catch
        disp(strcat('Error in processing', '- ', title_str))
    end
    plot_computed(trial_list, 'aniposeData_first_sc_relative_velocity', 'right_d2_knuckle_xyzSpeed', title_str, fsKinematic, fsEphys, 'refMax', annotateON, show_fig, save_fig, fullfile(save_loc, 'vel'));
    plot_computed_mean(trial_list, 'aniposeData_first_sc_relative_velocity', 'right_d2_knuckle_xyzSpeed', title_str, fsKinematic, fsEphys, '% reach', annotateON, show_fig, save_fig, fullfile(save_loc, 'avgvel'));
end