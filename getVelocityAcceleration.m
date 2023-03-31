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
% 	- num_points  int array, Number of points to use respectively for 1st, 2nd and 3rder order derivative
%				  Must be odd and > order of derivative + 1. Default = [3,5,7]
% Examples
% trial_list = getVelocityAcceleration(trial_list, 300);
% trial_list = getVelocityAcceleration(trial_list, 300, {'aniposeData_fixed'}, [7, 7, 7]);

% Data Labels to compute velocity and acceleration
if nargin<4
	num_points = [3, 5, 7];
end
if nargin<3
	processLabels = {'aniposeData_fixed_relative',...
					 'aniposeData_reach_relative',...
					 'aniposeData_grasp_relative'};
end

% Parameters for derivative
for trial_idx = 1:length(trial_list)
	for label_idx = 1:length(processLabels)
		dataTable = trial_list(trial_idx).(processLabels{label_idx});
		if istable(dataTable)
			data = table2array(dataTable);
			% Relative data consists of:
			%	- x,y,z wrt reference (water spout)
			%	- r, azi, el (of x,y,z wrt reference)
			% Vel & Accl contain the 1st & 2nd central derivative of the above
			velocity = central_derivative(data, fs, 1, num_points(1)); % Velocity: order = 1
			acceleration = central_derivative(data, fs, 2, num_points(2)); % Acceleration: order = 2
			jerk = central_derivative(data, fs, 3, num_points(3)); % Jerk: order = 3
			%% The above derivative of r (dr/dt) implies rate of change of relative displacement to reference
			%% and not the change from current to next position
			%% For the speed between two points, i.e. relative distance/ time between two positions,
			%% we have to use the dx, dy, dz
			%% i.e. speed = distance/time = sqrt(dx/dt^2 + dy/dt^2 + dz/dt^2)
			%% Also, note that even though x,y,z is wrt a reference i.e. xAct-xRef,
			%% dx eventually is wrt to two positions, i.e. xAct1-xRef - xAct2-xRef = xAct1-xAct2
			
			% Find the x locations (wrt to velocity but in this scenario, its same as input relative data) 
			colNames = trial_list(trial_idx).(processLabels{label_idx}).Properties.VariableNames;
			xLocation = strfind(colNames, '_x');
			xLocation = find(~cellfun(@isempty,xLocation));
			xyzLocation=[xLocation;xLocation+1;xLocation+2];
			xyzLocation=reshape(xyzLocation, 1,length(xLocation)*3);
			% Get speed between two points
			dxyzdt = velocity(:, xyzLocation);
			dxyzdt = reshape(dxyzdt, size(dxyzdt,1), 3, length(xLocation));
			[azimuth_dxyzdt, elevation_dxyzdt, r_dxyzdt] = cart2sph(dxyzdt(:,1,:),dxyzdt(:,2,:),dxyzdt(:,3,:));
			xyzSpeed = reshape(sqrt(sum(dxyzdt.^2, 2)), size(dxyzdt,1), length(xLocation));
			azimuth_dxyzdt = reshape(azimuth_dxyzdt, size(dxyzdt,1), length(xLocation));
			elevation_dxyzdt = reshape(elevation_dxyzdt, size(dxyzdt,1), length(xLocation));
			% Get acceleration between two points
			d2xyzdt2 = acceleration(:, xyzLocation);
			d2xyzdt2 = reshape(d2xyzdt2, size(d2xyzdt2,1), 3, length(xLocation));
			xyzAcc = reshape(sqrt(sum(d2xyzdt2.^2, 2)), size(d2xyzdt2,1), length(xLocation));
			% Get jerk between two points
			d3xyzdt3 = jerk(:, xyzLocation);
			d3xyzdt3 = reshape(d3xyzdt3, size(d3xyzdt3,1), 3, length(xLocation));
			xyzJerk = reshape(sqrt(sum(d3xyzdt3.^2, 2)), size(d3xyzdt3,1), length(xLocation));
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_velocity')) = array2table([velocity,...
																								 xyzSpeed,...
																								 azimuth_dxyzdt,...
																								 elevation_dxyzdt],...
																								'VariableNames', [colNames,...
																												  strcat(colNames(xLocation), 'yzSpeed'),...
																												  strcat(colNames(xLocation), 'yzAzi'),...
																												  strcat(colNames(xLocation), 'yzElev')]);
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_acceleration')) = array2table([acceleration,...
																									 xyzAcc],...
																									'VariableNames', [colNames,...
																												  	  strcat(colNames(xLocation), 'yzAcc')]);
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_jerk')) = array2table([jerk,...
																							 xyzJerk],...
																							 'VariableNames', [colNames,...
																											   strcat(colNames(xLocation), 'yzJerk')]);
		else
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_velocity')) = nan;
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_acceleration')) = nan;
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_jerk')) = nan;
		end
	end
end