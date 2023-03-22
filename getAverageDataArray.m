function [avgData, stdData] = getAverageDataArray(trialList, coordinateIndex, trialduration, fs)

    if nargin < 4
        fs = 30000;%for data sampled on openEphys
    end
    if nargin < 3
        trialduration = 1.0;
    end;
    if nargin < 2
        coordinateIndex=1.0;
    end
    % dataCombined = [];
    % max_time = round(trialduration*fs);
    % min_size = Inf;
    % max_size = -Inf;
    % for i = 1:length(trialList)
    %     trial = trialList(i);
    %     if isfield(trial.(colName), 'data')
    %         data = trial.(colName).data;
    %         if ~isnan(data);
    %             data=data(:,coordinateIndex);
    %         end
    %         if subtractStart
    %             data=data-data(1);
    %         end 
    %         if ~isnan(data)
    %             min_size = min(min_size, length(data(:,1)));
    %             max_size = max(max_size, length(data(:,1)));
    %             data = [data(:,1); repmat(nan, max_time-length(data(:,1)), 1)];
    %             dataCombined = [dataCombined, data];
    %         end
    %     end
    % end
    avgData = mean(trialList,'includenan');
    stdData =std(trialList,'includenan');
    % avgDataCombinedMinSize = mean(dataCombined(1:min_size,:), 2,'includenan');
    % avgDataCombinedMaxSize = mean(dataCombined(1:max_size,:), 2,'includenan');
end