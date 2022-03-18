% ls -1 */*_video > video_folders
% video_folder_raw
% original_dir

original_dir = pwd;
root_dir = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach'
cd(root_dir)
load('video_folder.mat');
for i = 1:size(video_folder_raw,1)
	path = video_folder_raw{i,2};
	disp(sprintf('Processing %s', path{1}));
	path_contents = dir(fullfile(original_dir, path{1}));
	path_contents = path_contents(3:end);
	for i = 1:length(path_contents);
		sep_loc = strfind(path_contents(i).name, '_');
		path_contents(i).file_number = str2num(path_contents(i).name(sep_loc(end)+1:sep_loc(end)+strfind(path_contents(i).name(sep_loc(end):end), '.tiff')-2));
		path_contents(i).set_index = str2num(path_contents(i).name(sep_loc(end-1)+1:sep_loc(end)-1));
	end
	[~,I1] = sort(arrayfun (@(x) x.set_index, path_contents));
	path_contents = path_contents(I1);
	[~,I2] = sort(arrayfun (@(x) x.file_number, path_contents));
	path_contents = path_contents(I2);
	[tiffFileLoc{1:length(path_contents)}] = deal(path_contents.folder);
	[tiffFileName{1:length(path_contents)}] = deal(path_contents.name);
	ffmpegInputFiles = strcat({'file '}, tiffFileLoc, {filesep}, tiffFileName);
	ffmpegInputCFileLabel = strrep(path{1},filesep,'_');
	ffmpegInputCFileName = strcat(ffmpegInputCFileLabel, '_tiff_filelist.txt');
	writecell(ffmpegInputFiles', ffmpegInputCFileName);
	command = strcat('ffmpeg -r 200 -f concat -safe 0 -i', {' '}, ffmpegInputCFileName, '  -s 512x512 -vcodec libx264 -pix_fmt yuv420p', {' '}, strcat(ffmpegInputCFileLabel, '.mp4'));
	[status, cmdout] = system(command{1});
end
cd(original_dir)