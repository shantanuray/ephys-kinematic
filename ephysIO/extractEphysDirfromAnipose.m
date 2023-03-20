function ephysLocInfo = extractEphysDirfromAnipose(anipose_dir)
% ephysLocInfo = extractEphysDirfromAnipos(anipose_dir)
% Returns a struct with location info of anipose and ephys data
% 	ephysLocInfo
% 		- label
% 		- anipose_dir
% 		- ephys_oebin
% Input char array with anipose dir (eg. 'headfixedreach/A1-1/AT_auto_manual_LightON_2021-09-24_16-29-56_video')

% init output
ephysLocInfo = struct();
ephysLocInfo.anipose_dir = anipose_dir;
[rootpath, anipose_label] = fileparts(anipose_dir);
ephysLocInfo.label = anipose_label(1:strfind(anipose_label, '_video') - 1);

% Ephys data is stored in
%	rootpath
%		ephys label (same as label above)
%			Record Node <number>
%				experiment<number>
%					recording<number>
%						structure.oebin
% Example
% 		headfixedreach/A1-1/AT_auto_manual_LightON_2021-09-24_16-29-56/Record Node 109/experiment2/recording1/structure.oebin
% 		headfixedreach/A1-1/AT_auto_manual_LightON_2021-09-24_16-29-56/Record Node 101/experiment2/recording1/structure.oebin
% Note: Choose the oebin with largest Record Node number
ephys_loc = fullfile(rootpath, ephysLocInfo.label);
oebin_dir = dir(fullfile(ephys_loc,...
						 'Record Node*',...
						 'experiment*',...
						 'recording*',...
						 'structure.oebin'));
[oebin_dir_list{1:length(oebin_dir),1}] = deal(oebin_dir.folder);
% Convert to string array for ease of indexing below
oebin_dir_list = string(oebin_dir_list);

dir_sep = strfind(oebin_dir_list, filesep, 'ForceCellOutput',true);	% Position of each file sep in file path
record_node_start = strfind(oebin_dir_list, 'Record Node', 'ForceCellOutput',true); % Start position of 'R' of Record Node in file path
record_node_num = [];	% Store the number after Record node
for i = 1:length(record_node_start)
	% Find sep location that is after Record Node to indicate end of Record Node <number? folder
	record_node_end = dir_sep{i}(dir_sep{i}>record_node_start{i, 1});
	% There are many folders after Record node. We want the file sep immediately after Record Node <number>
	record_node_end = record_node_end(1);
	% Extract the number immediately after 'Record Node' and before the filesep
	% It may contain a space between 'Record node' and the number, so use strip to remove
	% and since it is a string - convert to number
	record_node_num = [record_node_num;...
					   str2num(strip(oebin_dir_list{i}(record_node_start{i, 1}+length('Record Node'):record_node_end-1)))];
end
[max_record_num, oebin_dir_list_indx] = max(record_node_num);
ephysLocInfo.ephys_loc = fullfile(oebin_dir_list(oebin_dir_list_indx, :), 'structure.oebin');