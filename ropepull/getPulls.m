function data = getPulls(trial, colName, pkSegment, markerName)
	% data = getPulls(trial, 'speed', pkSegment);
	% data = getPulls(trial, 'speed', pkSegment, 'hand_left');

	data = trial.(colName)(pkSegment,:,:);
	if nargin==4
		markerNames = trial.markerNames;
		markerID = searchStrInCell(markerNames, markerName);
		data = data(:,markerID,:);
		data = squeeze(data);
	end
