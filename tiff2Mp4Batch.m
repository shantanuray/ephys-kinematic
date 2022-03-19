% ls -1 */*_video > video_folders
% video_folder_raw
% original_dir

original_dir = pwd;
root_dir = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach';
cd(root_dir);
load('video_folder.mat');
for i = 1:size(video_folder_raw,1)
	path = video_folder_raw{i,2}{1};
	disp(sprintf('Processing %s', path));
	path_contents = dir(path);
	tiff_filelist = struct();
	k = 0;
	for j = 1:length(path_contents)
		if ~isempty(strfind(path_contents(j).name, '.tiff'))
			k = k+1;
			tiff_filelist(k).name = path_contents(j).name;
			tiff_filelist(k).folder = path_contents(j).folder;
			sep_loc = strfind(tiff_filelist(k).name, '_');
			tiff_filelist(k)file_number = str2num( tiff_filelist(k)name(sep_loc(end)+1:sep_loc(end)+strfind( tiff_filelist(k)name(sep_loc(end):end), '.tiff')-2));
			tiff_filelist(k)set_index = str2num( tiff_filelist(k)name(sep_loc(end-1)+1:sep_loc(end)-1));
		end
	end
	[~,I1] = sort(arrayfun (@(x) x.set_index,  tiff_filelist));
	 tiff_filelist =  tiff_filelist(I1);
	[~,I2] = sort(arrayfun (@(x) x.file_number,  tiff_filelist));
	tiff_filelist =  tiff_filelist(I2);
	[tiffFileLoc{1:length( tiff_filelist)}] = deal(tiff_filelist.folder);
	[tiffFileName{1:length( tiff_filelist)}] = deal(tiff_filelist.name);
	ffmpegInputFiles = strcat({'file '}, tiffFileLoc, {filesep}, tiffFileName);
	ffmpegInputCFileLabel = strrep(path,filesep,'_');
	ffmpegInputCFileLabel = strrep(ffmpegInputCFileLabel,' ','_');
	ffmpegInputCFileName = strcat(ffmpegInputCFileLabel, '_tiff_filelist.txt');
	writecell(ffmpegInputFiles', ffmpegInputCFileName);
	command = strcat('ffmpeg -r 200 -f concat -safe 0 -i', {' '}, ffmpegInputCFileName, '  -s 512x512 -vcodec libx264 -pix_fmt yuv420p', {' '}, strcat(ffmpegInputCFileLabel, '.mp4'));
	status = system(command{1});
end
cd(original_dir)