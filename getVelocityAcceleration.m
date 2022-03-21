function trial_list = getVelocityAcceleration(trial_list, fs, processLabels, num_points)
% Adds velocity and acceleration to data
% Usage:
% trial_list = getVelocityAcceleration(trial_list, fs, processLabels, num_points);
% Input:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%	- fs: Sampling frequency (float)
%   - processLabels: cell array with data label names
%                 	 eg. {'anipose_fixed_relative'} or
%                     	 {'anipose_fixed', 'anipose_first_sc'}
% 					(Default) {'aniposeData_fixed_relative',...
% 					 			'aniposeData_first_sc_relative',...
% 					 			'aniposeData_last_sc_relative'};
% 	- num_points  int, optional (3,5,7,9)
%     			  Number of points to use, must be odd. Default = 3. (5/7/9/default)
% Examples
% trial_list = getVelocityAcceleration(trial_list, 300);
% trial_list = getVelocityAcceleration(trial_list, 300, {'aniposeData_fixed'}, 5);

% Data Labels to compute velocity and acceleration
if nargin<4
	num_points = 3;
end
if nargin<3
	processLabels = {'aniposeData_fixed_relative',...
					 'aniposeData_first_sc_relative',...
					 'aniposeData_last_sc_relative'};
end

% Parameters for derivative
for trial_idx = 1:length(trial_list)
	for label_idx = 1:length(processLabels)
		dataTable = trial_list(trial_idx).(processLabels{label_idx});
		data = table2array(dataTable);
		velocity = central_derivative(data, fs, 1, num_points); % Velocity: order = 1
		acceleration = central_derivative(data, fs, 2, num_points); % Acceleration: order = 2
		trial_list(trial_idx).(strcat(processLabels{label_idx}, '_velocity')) = array2table(velocity,...
																							'VariableNames', dataTable.Properties.VariableNames);
		trial_list(trial_idx).(strcat(processLabels{label_idx}, '_acceleration')) = array2table(acceleration,...
																							'VariableNames', dataTable.Properties.VariableNames); 
	end
end

