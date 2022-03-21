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
        filterAniposeFlag = true;
    case 'n'
        filterAniposeFlag = false;
    otherwise
        filterAniposeFlag = true;
end
if filterAniposeFlag
    % Default score threhold
    scoreThresh = 0.05;
    reply = input(['\nWhat is filter score threshold??? ',...
                   sprintf('[Click Enter to use default = (%.2f)]\n', scoreThresh)],...
                    's');
    if ~isempty(reply)
        scoreThresh = str2num(reply);
    end
end
fillMissingGapSize = 50;
fixedReachInterval = 150; % # of samples at 200 Hz
% Pass parameters to batch function
processAniposeEphysBatch(root_dir,...
                         save_dir,...
                         'FilterAniposeFlag', filterAniposeFlag,...
                         'ScoreThresh', scoreThresh,...
                         'MaxGap', fillMissingGapSize,...
                         'FixedReachInterval', fixedReachInterval);