% Get root directory with all of the anipose and ephys data
disp('Choose the root directory with all of the anipose and ephys data')
root_dir = uigetdir('.', 'Choose root directory with all of the anipose and ephys data');

% Get save directory
disp('Choose common location to save trials')
save_dir = uigetdir('.', 'Choose common location to save trials');

reply = input(['\nDo you wish filter anipose data??\n\n',...
            '[Enter/y/Y]    => Yes\n',...
            '[n/N]          => No    \n'],'s');
switch lower(reply)
    case 'y'
        filter_anipose_flag = true;
    case 'n'
        filter_anipose_flag = false;
    otherwise
        filter_anipose_flag = true;
end
if filter_anipose_flag
    % Default score threhold
    scoreThresh = 0.05;
    reply = input(['\nWhat is filter score threshold??? ',...
                   sprintf('[Click Enter to use default = (%.2f)]\n', scoreThresh)],...
                    's');
    if ~isempty(reply)
        scoreThresh = str2num(reply);
    end
end
fillmissing_gapsize = 50;
% Pass parameters to batch function
processAniposeEphysBatch(root_dir,
                         save_dir,
                         'FixedReachEstTmeMS', reachEstTimeMS,
                         'FilterAniposeFlag', filter_anipose_flag,
                         'ScoreThresh', scoreThresh,
                         'MaxGap', fillmissing_gapsize);