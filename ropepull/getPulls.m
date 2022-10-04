function data = getPulls(trial, colName, pkSegment, markerName)
	% data = getPulls(trial, 'speed', pkSegment);
	% data = getPulls(trial, 'speed', pkSegment, 'hand_left');

	if ~isnan(pkSegment)
		data = trial.(colName)(pkSegment,:,:);
    	if nargin==4 & size(data, 2) > 1
    		markerNames = trial.markerNames;
    		markerID = searchStrInCell(markerNames, markerName);
    		data = data(:,markerID,:);
    		data = squeeze(data);
    	end
    else
        data = nan;
    end
end
