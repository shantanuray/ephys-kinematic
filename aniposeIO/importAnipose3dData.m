function [aniposeData] = importAnipose3dData(analysisFolder)
% Function to import Anipose 3d-pose and angles output data (.csv files)
% and concatenate the data tables into a single data table. This function
% will also include the video number in the video series (e.g. trials)
% under the column 'videoNumber'.
%
% If the user does not specify a folder path as an input argument, a UI
% window will open to prompt the user to navigate to the folder containing
% the Anipose output subfolders.
%
% MNL-E | KW
% Written in MATLAB r2020b
% Last updated: 01/28/2022

%% Get folder containing the subfolders 'pose-3d' and 'angles'
if (nargin == 0)
    analysisFolder = uigetdir(pwd, 'Select the folder containing the Anipose output subfolders (pose-3d, angles)');
end

%% Loop through the files in 'pose-3d' and 'angles' import position data tables and angle data tables from csv files
fileList = dir(fullfile(analysisFolder, 'pose-3d', '*.csv'));
% fileList = natsortfiles(fileList);
posData = [];
for i=1:length(fileList)
    tmp = readtable(fullfile(fileList(i).folder, fileList(i).name));
    tmp.fnum = [];
    posData = [posData;tmp];
end
cd ..
fileList = dir(fullfile(analysisFolder, 'angles', '*.csv'));
% fileList = natsortfiles(fileList);
angleData = [];
for i=1:length(fileList)
    tmp = readtable(fullfile(fileList(i).folder, fileList(i).name));
    tmp.videoNumber = repmat(i,size(tmp,1),1);
    angleData = [angleData;tmp];
end
aniposeData = [posData, angleData];
