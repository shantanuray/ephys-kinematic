
addpath ~/Projects/ephys-kinematic
addpath ~/Projects/npy-matlab/npy-matlab
i = 1;
anipose_dir_list{i} = '/mnle/data/AYESHA_THANAWALLA/Cerebellar_nuclei/INTRSECT/Behavior/headfixedwaterreach/A1-2/AT_A1-2_2021-09-08_14-01-05_hfwr_manualLightOn_090821_212pm_video/pose-3d';

disp(sprintf('Initiating processing %s', anipose_dir_list{i}));
indicator = 'pose-3d';
dir_sep = strfind(anipose_dir_list{i},indicator);
dir_sep = dir_sep - 2;
aniposedir_root = anipose_dir_list{i}(1:dir_sep);
anipose_ephys_loc = extractAniposeEphysDir(aniposedir_root);

aniposeData = importAnipose3dData(aniposedir_root);
[EMG_trap,EMG_biceps,EMG_triceps,EMG_ecu,frameTrig,laserTrig,tone_on,tone_off,solenoid_on,solenoid_off,perchContact_on,perchContact_off,spoutContact_on,spoutContact_off,videoFrames_timestamps,videoFrames_timeInSeconds,aniposeData] = loadOEbinary_AT(anipose_ephys_loc.ephys_loc, aniposeData);

ephys_fs = 30000;
fixed_int_ms = 200;
fixed_int_ts = fixed_int_ms*ephys_fs/1000; % 200ms
trial_list = trial_segmentation(aniposeData, solenoid_on, spoutContact_on, videoFrames_timestamps, laserTrig, EMG_biceps, EMG_triceps, EMG_ecu, EMG_trap, fixed_int_ts);