root_dir = '/Users/ayesha/Dropbox/Ayesha_post doc_local storage/Cerebellar_nuclei/INTRSECT/behavior/hfwr/A11-1/data/filtered_test';
refLabel = 'waterSpout';
ref2max = true;
fsKinematic = 200;
fsEphys = 30000;
save_loc = root_dir;
summary_filename = 'summaryTable_A11-1_test';

startEvents = {'tone_on'};
for sevt = 1:length(startEvents)
    disp(startEvents{sevt})
    %mat_list = dir(fullfile(root_dir, strcat('A*', repmat('_',length(startEvents{sevt})>0), startEvents{sevt}, '_filtered.mat')));
    mat_list = dir(fullfile(root_dir, strcat('A*', repmat('_',length(startEvents{sevt})>0), startEvents{sevt},'.mat')));

    disp(sprintf('Found %d MAT files', length(mat_list)));
    summaryTable = table();
    for mat_indx = 1:length(mat_list)
        % mat_file = mat_list{mat_indx};
        mat_file = fullfile(mat_list(mat_indx).folder, mat_list(mat_indx).name);
        [fpath, title_str, ext] = fileparts(mat_file);
        disp(sprintf('Loading %s', mat_file));
        trial_list = [];
        var_name = strcat('trialList', repmat('_',length(startEvents{sevt})>0), startEvents{sevt});
        load(mat_file, var_name);
        eval(['trial_list = ', var_name, ';']);
        disp(sprintf('Getting summary info for %d trials', length(trial_list)));
        %summaryTrial = getSummaryInfo(trial_list, fsKinematic, title_str, 'right_d3_knuckle', 'aniposeData_first_sc');
        summaryTrial = getSummaryInfo_03272023(trial_list, fsKinematic, title_str, 'right_wrist', 'aniposeData_reach');
        summaryTable = [summaryTable; summaryTrial];
    end
    %save(fullfile(save_loc, strcat(summary_filename, '_', startEvents{sevt}, '.mat')), 'summaryTable');
    writetable(summaryTable,...
        fullfile(save_loc, strcat(summary_filename, '_', startEvents{sevt}, '.xlsx')),...
        'Sheet', 1, 'Range', 'A1');
end