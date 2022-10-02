function trialList = updateTrialListAccelerationPeaks(trialList, varargin)
	% trialList = updateTrials(trialList);
	% 	Update acceleration segments of trial list with num peaks
	p = readInput(varargin);
	[peakAnalysisColNames] = parseInput(p.Results);
    dataExists = false;
	for t = 1:length(trialList)
		for col = 1:length(peakAnalysisColNames)
            dataExists = false;
            if strfind(lower(peakAnalysisColNames{col}), 'first') & ~isnan(trialList(t).('firstPkSegmentT'))
                dataExists = true;
            elseif strfind(lower(peakAnalysisColNames{col}), 'pre') & iscell(trialList(t).('segmentPreT'))
                dataExists = true;
            elseif strfind(lower(peakAnalysisColNames{col}), 'post') & iscell(trialList(t).('segmentPostT'))
                dataExists = true;
            end
            if dataExists
                trialList(t).(peakAnalysisColNames{col}).('NumPeaks') = getSegmentNumPeaks(trialList(t), peakAnalysisColNames{col});
            end
		end
	end

	%% Read input
	function p = readInput(input)
	    p = inputParser;
		peakAnalysisColNames = {
		'accelerationFirstPullData',...
		'accelerationRhythymicPeakPreVhand_right',...
		'accelerationRhythymicPeakPreVhand_left',...
		'accelerationRhythymicPeakPostVhand_right',...
		'accelerationRhythymicPeakPostVhand_left',...
		};

	    addParameter(p,'PeakAnalysisColNames',peakAnalysisColNames, @iscell);
	    parse(p, input{:});
	end
	function [peakAnalysisColNames] = parseInput(p)
	    peakAnalysisColNames = p.PeakAnalysisColNames;
	end
end