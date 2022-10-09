function [avgDataCombined, avgDataCombinedMaxSize, avgDataCombinedMinSize] = getAverageData(trialList, colName, coordinateIndex, subtractStart, trialduration, fs)

    if nargin < 6
        fs = 200;
    end
    if nargin < 5
        trialduration = 8.0;
    end;
    if nargin < 4
        subtractStart = false;
    end
    dataCombined = [];
    max_time = round(trialduration*fs);
    min_size = Inf;
    max_size = -Inf;
    for i = 1:length(trialList)
        trial = trialList(i);
        if isfield(trial.(colName), 'data')
            data = trial.(colName).data;
            if ~isnan(data);
                data=data(:,coordinateIndex);
            end
            if subtractStart
                data=data-data(1);
            end 
            if ~isnan(data)
                min_size = min(min_size, length(data(:,1)));
                max_size = max(max_size, length(data(:,1)));
                data = [data(:,1); repmat(nan, max_time-length(data(:,1)), 1)];
                dataCombined = [dataCombined, data];
            end
        end
    end
    avgDataCombined = mean(dataCombined, 2,'omitnan');
    avgDataCombinedMinSize = mean(dataCombined(1:min_size,:), 2,'omitnan');
    avgDataCombinedMaxSize = mean(dataCombined(1:max_size,:), 2,'omitnan');
end
