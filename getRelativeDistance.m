function trial_list = getRelativeDistance(trial_list, processLabels, refLabel)
% Usage: getRelativeDistance(trial_list, dataLabels, refLabel);
% Adds relative distance wrt x,y,z axes as well as absolute r, azimuth, elevation
% Input:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed'} or
%                     {'anipose_fixed', 'anipose_first_sc'}
%				  (default: {'aniposeData_fixed',...
%					 		'aniposeData_first_sc',...
%					 		'aniposeData_last_sc'})
%   - refLabel:   string indicating reference (default: 'waterSpout')
% Examples
% trial_list = getRelativeDistance(trial_list, processLabels, refLabel);
% trial_list = getRelativeDistance(trial_list, {'aniposeData_fixed'});
% trial_list = getRelativeDistance(trial_list, {'aniposeData_fixed'}, 'waterSpout');

% Assumption: Data is stored in a table in the following structure for each body part/ reference
%	left_wrist_x,left_wrist_y,left_wrist_z,left_wrist_error,left_wrist_ncams,left_wrist_score,left_d1_knuckle_x,...
%	Calculate and save relative distance for x,y,z only


% Data Labels to compute velocity and acceleration
if nargin<3
	refLabel = 'waterSpout';
end
if nargin<2
	processLabels = {'aniposeData_fixed',...
					 'aniposeData_first_sc',...
					 'aniposeData_last_sc'};
end

% Parameters for derivative
for trial_idx = 1:length(trial_list)
	for label_idx = 1:length(processLabels)
		dataTable = trial_list(trial_idx).(processLabels{label_idx});
		if ~isempty(dataTable)
			colNames = dataTable.Properties.VariableNames;
			xLocation = strfind(colNames, '_x');
			xLocation = find(~cellfun(@isempty,xLocation));
			xyzLocation=[xLocation;xLocation+1;xLocation+2];
			xyzLocation=reshape(xyzLocation, 1,length(xLocation)*3);
			refLocation = strfind(colNames, refLabel);
			refLocation = find(~cellfun(@isempty,refLocation));
			refLocation = refLocation(1:3);  % x,y,z only
			data = table2array(dataTable);
			dataref = repmat(data(1, refLocation), size(dataTable, 1), 1); % Replicate for all time instances
			dataref = repmat(dataref, 1, 1, length(xLocation));			   % Replicate for all body parts (#samples x 3 x bodyparts)
			dataxyz = data(:, xyzLocation);								   % Get XYZ of all body parts
			dataxyz = reshape(dataxyz, size(dataxyz,1), 3, length(xLocation));  % Reshape to #samples x 3 x bodyparts
			xyzRel = dataxyz-dataref;
			[azimuth_rel, elevation_rel, r_rel] = cart2sph(xyzRel(:,1,:),xyzRel(:,2,:),xyzRel(:,3,:));
			dataRel = cat(2, xyzRel, r_rel, azimuth_rel, elevation_rel);
			dataRel = reshape(dataRel, size(dataRel,1), size(dataRel,2)*size(dataRel,3)); % Flatten it back
			for bodyPart_idx = 1:length(xLocation)
				base_label = colNames{xLocation(bodyPart_idx)}(1:strfind(colNames{xLocation(bodyPart_idx)}, '_x')-1);
				dataRel_labels{(bodyPart_idx-1)*6+1} = strcat(base_label, '_x');
				dataRel_labels{(bodyPart_idx-1)*6+2} = strcat(base_label, '_y');
				dataRel_labels{(bodyPart_idx-1)*6+3} = strcat(base_label, '_z');
				dataRel_labels{(bodyPart_idx-1)*6+4} = strcat(base_label, '_r');
				dataRel_labels{(bodyPart_idx-1)*6+5} = strcat(base_label, '_azimuth');
				dataRel_labels{(bodyPart_idx-1)*6+6} = strcat(base_label, '_elevation');
			end
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_relative')) = array2table(dataRel,...
																								'VariableNames', dataRel_labels);
		else
			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_relative')) = array2table([]);
		end
	end
end

