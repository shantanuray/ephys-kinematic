function [spoutContact_on_first, spoutContact_on_multi, hitormiss, perchOnStart] = getSpoutContact(startTrialTrigger, spoutContact_on, perchContact_cont)
	% [spoutContact_on_first, spoutContact_on_multi, hitormiss] = getSpoutContact(startTrialTrigger, spoutContact_on)
	% Inputs:
	%	- startTrialTrigger: solenoid_on or tone_on events - Marks the start of trial
	% 	- spoutContact_on: Spout contact events (reward)
	% startTrialTrigger and spoutContact_on are wrt eventData.Timestamps
	% Outputs:
	% 	- spoutContact_on_first: First spout contact immediately after each startTrialTrigger and before next startTrialTrigger
	% 	- spoutContact_on_multi: All spout contacts between each startTrialTrigger and before next startTrialTrigger
	%	- hitormiss: If no spout contact for given startTrialTrigger (1 - hit; 0 - miss)

	if nargin<3
		perchContact_cont = [];
	end
	spoutContact_on_first = [];% creates an empty array for the first spout contact after each reward presentation (startTrialTrigger) which can be filled with values generated below
	spoutContact_on_multi = cell(length(startTrialTrigger), 1);% creates an empty array for the all spout contacts after each reward presentation (startTrialTrigger) and before next reward presentation
	hitormiss = zeros(length(startTrialTrigger), 1);
	perchOnStart = zeros(length(startTrialTrigger), 1); % By default, assume hand on perch at start of trial
	for i = 1:length(startTrialTrigger) % starts a for loop which will cycle through all the values in startTrialTrigger
		first_sc_index = find(spoutContact_on > startTrialTrigger(i)); %defines a variable tmp_index that for all values of solenoid on finds the value in spoutContact_on that is higher
		if isempty(first_sc_index)
			%  starts an if statement that writes an NaN in case the last value of solenoid on does not have a spoutconact after i.e mouse did not reach
			curr_spoutContact_on = nan;
		else
			curr_spoutContact_on = spoutContact_on(first_sc_index(1));
		end
		if i < length(startTrialTrigger) %starts an if statement, where for all values except the last index value, the code checks that the spoutContact value corresponds to the current startTrialTrigger value and not the next 
			if ~isempty(first_sc_index)
				if (spoutContact_on(first_sc_index(1)) > startTrialTrigger(i+1))
		   			spoutContact_on_first = [spoutContact_on_first; nan];
				else
					hitormiss(i) = 1;
					% Find all spout contacts after each reward presentation (startTrialTrigger) and before next reward presentation
					all_sc_index = find(spoutContact_on(first_sc_index) < startTrialTrigger(i+1));
					spoutContact_on_multi{i} = spoutContact_on(all_sc_index + first_sc_index(1) - 1);
					% Note first spout contact
			 		spoutContact_on_first = [spoutContact_on_first; curr_spoutContact_on]; 
			 	end
			 end
		else
			if ~isempty(first_sc_index)
				hitormiss(i) = 1;
			end
			spoutContact_on_first = [spoutContact_on_first; curr_spoutContact_on]; % for the last value, do not check the next value because it will be empty 
			spoutContact_on_multi{i} = [curr_spoutContact_on];
		end
		if sum(startTrialTrigger(i) == find(perchContact_cont)) > 0
			perchOnStart(i) = 1;
		end
	end
end