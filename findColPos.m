function colPos = findColPos(dataTable, colLabelStrCell)
% colPos = findColPos(dataTable, colLabelStrCell);
% Find column names of table dataTable that "contain" column labels specified in colLabelStrCell
% and return column position of matching column names
% 
% Arguments:
%   - dataTable: Input table
%   - colLabelStrCell: str or cell of str with pattern for finding appropriate columns in table (eg. '_x')
%
% Returns:
%   - colPos: Array of column indexes of table VariableNames that contain strings in colLabelStrCell
%
% Examples:
% % Assumption:
% % aniPoseData with columns such as {'<body_part>_x', '<body_part>_y', '<body_part>_z', '<body_part>_score', '<body_part>_error', ...}
% % Goal: Extract column positions of (x,y,z) data
% colPos = findColPos(aniPoseData, {'_x', '_y', '_z'});

colPos = [];
if ~isempty(dataTable)
    % Get table column names
    colNames = dataTable.Properties.VariableNames;
    % Check if patterns have been provided for matching column names 
    if ~isempty(colLabelStrCell)
        if isstr(colLabelStrCell)
            colLabelStrCell = {colLabelStrCell};
        end
        % Check if patterns are strings (cell of strings)
        if ~iscellstr(colLabelStrCell)
            error("findColPos: colLabelStrCell is not a valid cell of strings")
        end
        
        for lblIdx = 1:length(colLabelStrCell)
            % Find column name that contains label
            lblPos = strfind(colNames, colLabelStrCell{lblIdx});
            lblPos = find(~cellfun(@isempty, lblPos));
            % Append
            colPos = [colPos, lblPos];
        end
        % It may be desirable to sort the column positions so that they are aggregated in functional groups (eg. body parts) and not the matching label (eg. 'x')
        colPos = sort(colPos);
    else
        error("findColPos: No patterns provided to match table variable names")
    end
else
    warning("findColPos: empty table provided. Skipping")
end