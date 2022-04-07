root_dir = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/';
% root_dir = "C:\Users\shantanu.ray\Documents\MATLAB";
dataLabels = {'aniposeData_fixed_relative_velocity'};
refLabel = 'waterSpout';
ref2max = true;
fsKinematic = 200;
fsEphys = 30000;
annotateON = true;
show_fig = false;
save_fig = true;
save_loc = root_dir;
alignBy = '% reach';

mat_list = dir(fullfile(root_dir, 'AT*.mat'));
out = {};
for mat_indx = 1:length(mat_list)
    mat_file = fullfile(mat_list(mat_indx).folder, mat_list(mat_indx).name);
    [fpath, title_str, ext] = fileparts(mat_list(mat_indx).name);
    mat_file = fullfile(mat_list(mat_indx).folder, mat_list(mat_indx).name)
    trial_list = [];
    load(mat_file, 'trial_list');
    plot_3Ddata(trial_list, {'aniposeData_first_sc'}, 'right_d2_knuckle', fsKinematic, fsEphys, title_str, refLabel, annotateON, show_fig, save_fig, save_loc);
    plot_computed(trial_list, {'aniposeData_fixed_relative_velocity'}, 'right_d2_knuckle_xyzSpeed', title_str, fsKinematic, fsEphys, 'ref2max', annotateON, show_fig, save_fig, save_loc);
    [spoutContact_ON, spoutContact_OFF, lightON] = plot_computed_mean(trial_list, {'aniposeData_first_sc_relative_velocity'}, 'right_d2_knuckle_xyzSpeed', title_str, fsKinematic, fsEphys, '% reach', annotateON, show_fig, save_fig, save_loc);
    save(mat_file, '-append', 'spoutContact_ON', 'spoutContact_OFF', 'lightON');
end