function anipose_dir_list = listAniposeDir(rootdir, indicator)
% anipose_dir_list = listAniposeDir(./acme);
% anipose_dir_list = listAniposeDir();
% anipose_dir_list = listAniposeDir(./acme, 'pose-3d')
% Returns list of all dir with anipose data

% Init output
anipose_dir_list = {};

% Default indicator - 'pose-3d'
if nargin < 2
	indicator = 'pose-3d';
end

if nargin < 1
	rootdir = uigetdir();
end

% get all indicator dir (eg. pose-3d)
indicator_dir_list = dir(fullfile(rootdir, strcat('*_video', filesep, '*', indicator)));
% Should be dir by default, but double check
idx = find([indicator_dir_list.isdir]);

% Get parent of indicator dir (dir.folder)
[anipose_dir_list{1:length(idx),1}] = deal(indicator_dir_list(idx).folder);
% Should be unique, but double check
anipose_dir_list = unique(anipose_dir_list);