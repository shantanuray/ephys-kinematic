function trial_list = getGripAperture(trial_list, processLabels, digit1label, digit2label)
% Usage: getGripAperture(trial_list, dataLabels, digit1label,digit2label);
% calculates the distance between digits specified, for classical grip aperture  calculations the tip of d2 and d5 would be used , but other markers such as the knuckle or other digits coulber be considered 
% Input:
%   - trial_list: list of segmented trials with reach data (see trial_segmentation.m)
%   - dataLabels: cell array with data label names
%                 eg. {'anipose_fixed'} or
%                     {'anipose_fixed', 'anipose_first_sc'}
%				  (default: {'aniposeData_fixed',...
%					 		'aniposeData_first_sc',...
%					 		'aniposeData_last_sc'})
%   - digit1label:   string indicating digit1label (default: 'right_d5_tip')
%   - digit2label:   string indicating digit2label (default:  'right_d2_tip')
% Examples
% trial_list = getRelativeDistance(trial_list, {'aniposeData_fixed'});
% trial_list = getRelativeDistance(trial_list, {'aniposeData_fixed'}, 'right_d5_tip','right_d2_tip');

% Assumption: Data is stored in a table in the following structure for each body part/ reference
%	left_wrist_x,left_wrist_y,left_wrist_z,left_wrist_error,left_wrist_ncams,left_wrist_score,left_d1_knuckle_x,...
%	Calculate and save relative distance for x,y,z only


if nargin<4
	 digit2label= 'right_d2_tip';
end
if nargin<3
	digit1label = 'right_d5_tip';
end
if nargin<2
	processLabels = {'aniposeData_fixed',...
					         'aniposeData_first_sc',...
					         'aniposeData_last_sc',...
					         'aniposeData_fixed_relative',...
					         'aniposeData_first_sc_relative',...
					         'aniposeData_last_sc_relative'};
end


for trial_idx = 1:length(trial_list)
	for label_idx = 1:length(processLabels)
		dataTable = trial_list(trial_idx).(processLabels{label_idx});
		if ~isempty(dataTable)
			colNames = dataTable.Properties.VariableNames;
			% xLocation = strfind(colNames, '_x');
			% xLocation = find(~cellfun(@isempty,xLocation));
			% xyzLocation=[xLocation;xLocation+1;xLocation+2];
			% xyzLocation=reshape(xyzLocation, 1,length(xLocation)*3);
			digit1Location = strfind(colNames, digit1Label);
			digit1Location = find(~cellfun(@isempty,digit1Location));
			digit1Location = digit1Location(1:3);  
			data = table2array(dataTable);
			digit1Value = data(:, digit1Location), 1);
      digit2Location = strfind(colNames, digit2Label);
			digit2Location = find(~cellfun(@isempty,digit2Location));
			digit2Location = digit2Location(1:3);  % x,y,z only , change to average of all datapoints
			data = table2array(dataTable);
			digit2Value = data(:, digit2Location), 1);
      gripAperture=digit2Value-digit1Value% 

      %I want to add this as a column to data rel and the raw data 

% 			%dataref = repmat(refValue, size(dataTable, 1), 1); % Replicate for all time instances
% 			%dataref = repmat(dataref, 1, 1, length(xLocation));			   % Replicate for all body parts (#samples x 3 x bodyparts)
% 			dataxyz = data(:, xyzLocation);								   % Get XYZ of all body parts
% 			dataxyz = reshape(dataxyz, size(dataxyz,1), 3, length(xLocation));  % Reshape to #samples x 3 x bodyparts
% 			xyzRel = dataxyz-dataref;
% 			[azimuth_rel, elevation_rel, r_rel] = cart2sph(xyzRel(:,1,:),xyzRel(:,2,:),xyzRel(:,3,:));
% 			[l, roc, k] = arrayfun(@(i)curvature(xyzRel(:,:,i)), 1:size(xyzRel, 3), 'UniformOutput', false);
% 			arc_length = cat(2, l{:,:});
% 			arc_length = reshape(arc_length, size(arc_length,1), 1, size(arc_length,2));
% 			radius_of_curvature = cat(2, roc{:,:});
% 			radius_of_curvature = reshape(radius_of_curvature, size(radius_of_curvature,1), 1, size(radius_of_curvature,2));
% 			dataRel = cat(2, xyzRel, r_rel, azimuth_rel, elevation_rel, arc_length, radius_of_curvature);
% 			num_labels = size(dataRel,2);
% 			dataRelFlat = reshape(dataRel, size(dataRel,1), size(dataRel,2)*size(dataRel,3)); % Flatten it back
% 			for bodyPart_idx = 1:length(xLocation)
% 				base_label = colNames{xLocation(bodyPart_idx)}(1:strfind(colNames{xLocation(bodyPart_idx)}, '_x')-1);
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+1} = strcat(base_label, '_x');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+2} = strcat(base_label, '_y');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+3} = strcat(base_label, '_z');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+4} = strcat(base_label, '_r');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+5} = strcat(base_label, '_azimuth');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+6} = strcat(base_label, '_elevation');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+7} = strcat(base_label, '_arc_length');
% 				dataRel_labels{(bodyPart_idx-1)*num_labels+8} = strcat(base_label, '_radius_of_curvature');
% 			end
% 			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_relative')) = ...
% 			array2table(dataRelFlat, 'VariableNames', dataRel_labels);
% 		else
% 			trial_list(trial_idx).(strcat(processLabels{label_idx}, '_relative')) = array2table([]);
% 		end
% 	end
% end

