function [aniposeData_filtered] = filterAniposeDataTable(aniposeData, scoreThresh)
% Function to filter Anipose data table (from importAnipose3dData) by a
% score threshold. Outputs a data table where coordinate and angle values
% with likelihood/scores below threshold are set to NaN. Values that are
% removed can be interpolated/imputed later.
%
% MNL-E | KW
% Written in MATLAB r2020b
% Last updated: 1/25/2022

%% Initialize
aniposeData_filtered = aniposeData;

%% XYZ coordinates
nLandmarks = 35;
for i=1:nLandmarks
    score = aniposeData_filtered{:,i*6};
    score(isnan(score)) = 0;
    x = aniposeData_filtered{:,(i-1)*6+1};
    y = aniposeData_filtered{:,(i-1)*6+2};
    z = aniposeData_filtered{:,(i-1)*6+3};
    x(score < scoreThresh) = nan;
    y(score < scoreThresh) = nan;
    z(score < scoreThresh) = nan;
    aniposeData_filtered{:,i*6} = score; 
    aniposeData_filtered{:,(i-1)*6+1} = x;
    aniposeData_filtered{:,(i-1)*6+2} = y;
    aniposeData_filtered{:,(i-1)*6+3} = z;
end

%% Angles
% We'll need to filter angles separately ("brute force") since each angle
% needs to be filtered by the scores of all 3 landmarks used to define the
% angle, and the column indices are not in a regular pattern.

% Get scores
right_wrist_score = aniposeData_filtered.right_wrist_score;
right_d2_knuckle_score = aniposeData_filtered.right_d2_knuckle_score;
right_d3_knuckle_score = aniposeData_filtered.right_d3_knuckle_score;
right_d4_knuckle_score = aniposeData_filtered.right_d4_knuckle_score;
right_d5_knuckle_score = aniposeData_filtered.right_d5_knuckle_score;
right_d2_mid_score = aniposeData_filtered.right_d2_mid_score;
right_d3_mid_score = aniposeData_filtered.right_d3_mid_score;
right_d4_mid_score = aniposeData_filtered.right_d4_mid_score;
right_d5_mid_score = aniposeData_filtered.right_d5_mid_score;
right_d2_tip_score = aniposeData_filtered.right_d2_tip_score;
right_d3_tip_score = aniposeData_filtered.right_d3_tip_score;
right_d4_tip_score = aniposeData_filtered.right_d4_tip_score;
right_d5_tip_score = aniposeData_filtered.right_d5_tip_score;

left_wrist_score = aniposeData_filtered.left_wrist_score;
left_d2_knuckle_score = aniposeData_filtered.left_d2_knuckle_score;
left_d3_knuckle_score = aniposeData_filtered.left_d3_knuckle_score;
left_d4_knuckle_score = aniposeData_filtered.left_d4_knuckle_score;
left_d5_knuckle_score = aniposeData_filtered.left_d5_knuckle_score;
left_d2_mid_score = aniposeData_filtered.left_d2_mid_score;
left_d3_mid_score = aniposeData_filtered.left_d3_mid_score;
left_d4_mid_score = aniposeData_filtered.left_d4_mid_score;
left_d5_mid_score = aniposeData_filtered.left_d5_mid_score;
left_d2_tip_score = aniposeData_filtered.left_d2_tip_score;
left_d3_tip_score = aniposeData_filtered.left_d3_tip_score;
left_d4_tip_score = aniposeData_filtered.left_d4_tip_score;
left_d5_tip_score = aniposeData_filtered.left_d5_tip_score;

% right_d2_knuckle_flex
right_d2_knuckle_flex_filter = (right_wrist_score < scoreThresh) | (right_d2_knuckle_score < scoreThresh) | (right_d2_mid_score < scoreThresh);
aniposeData_filtered.right_d2_knuckle_flex(right_d2_knuckle_flex_filter) = nan;

% right_d3_knuckle_flex
right_d3_knuckle_flex_filter = (right_wrist_score < scoreThresh) | (right_d3_knuckle_score < scoreThresh) | (right_d3_mid_score < scoreThresh);
aniposeData_filtered.right_d3_knuckle_flex(right_d3_knuckle_flex_filter) = nan;

% right_d4_knuckle_flex
right_d4_knuckle_flex_filter = (right_wrist_score < scoreThresh) | (right_d4_knuckle_score < scoreThresh) | (right_d4_mid_score < scoreThresh);
aniposeData_filtered.right_d4_knuckle_flex(right_d4_knuckle_flex_filter) = nan;

% right_d5_knuckle_flex
right_d5_knuckle_flex_filter = (right_wrist_score < scoreThresh) | (right_d5_knuckle_score < scoreThresh) | (right_d5_mid_score < scoreThresh);
aniposeData_filtered.right_d5_knuckle_flex(right_d5_knuckle_flex_filter) = nan;

% right_d2_mid_flex
right_d2_mid_flex_filter = (right_d2_knuckle_score < scoreThresh) | (right_d2_mid_score < scoreThresh) | (right_d2_tip_score < scoreThresh);
aniposeData_filtered.right_d2_mid_flex(right_d2_mid_flex_filter) = nan;

% right_d3_mid_flex
right_d3_mid_flex_filter = (right_d3_knuckle_score < scoreThresh) | (right_d3_mid_score < scoreThresh) | (right_d3_tip_score < scoreThresh);
aniposeData_filtered.right_d3_mid_flex(right_d3_mid_flex_filter) = nan;

% right_d4_mid_flex
right_d4_mid_flex_filter = (right_d4_knuckle_score < scoreThresh) | (right_d4_mid_score < scoreThresh) | (right_d4_tip_score < scoreThresh);
aniposeData_filtered.right_d4_mid_flex(right_d4_mid_flex_filter) = nan;

% right_d5_mid_flex
right_d5_mid_flex_filter = (right_d5_knuckle_score < scoreThresh) | (right_d5_mid_score < scoreThresh) | (right_d5_tip_score < scoreThresh);
aniposeData_filtered.right_d5_mid_flex(right_d5_mid_flex_filter) = nan;

% right_wrist_axis
right_wrist_axis_filter = (right_wrist_score < scoreThresh) | (right_d3_knuckle_score < scoreThresh) | (right_d4_knuckle_score < scoreThresh);
aniposeData_filtered.right_wrist_axis(right_wrist_axis_filter) = nan;

% left_d2_knuckle_flex
left_d2_knuckle_flex_filter = (left_wrist_score < scoreThresh) | (left_d2_knuckle_score < scoreThresh) | (left_d2_mid_score < scoreThresh);
aniposeData_filtered.left_d2_knuckle_flex(left_d2_knuckle_flex_filter) = nan;

% left_d3_knuckle_flex
left_d3_knuckle_flex_filter = (left_wrist_score < scoreThresh) | (left_d3_knuckle_score < scoreThresh) | (left_d3_mid_score < scoreThresh);
aniposeData_filtered.left_d3_knuckle_flex(left_d3_knuckle_flex_filter) = nan;

% left_d4_knuckle_flex
left_d4_knuckle_flex_filter = (left_wrist_score < scoreThresh) | (left_d4_knuckle_score < scoreThresh) | (left_d4_mid_score < scoreThresh);
aniposeData_filtered.left_d4_knuckle_flex(left_d4_knuckle_flex_filter) = nan;

% left_d5_knuckle_flex
left_d5_knuckle_flex_filter = (left_wrist_score < scoreThresh) | (left_d5_knuckle_score < scoreThresh) | (left_d5_mid_score < scoreThresh);
aniposeData_filtered.left_d5_knuckle_flex(left_d5_knuckle_flex_filter) = nan;

% left_d2_mid_flex
left_d2_mid_flex_filter = (left_d2_knuckle_score < scoreThresh) | (left_d2_mid_score < scoreThresh) | (left_d2_tip_score < scoreThresh);
aniposeData_filtered.left_d2_mid_flex(left_d2_mid_flex_filter) = nan;

% left_d3_mid_flex
left_d3_mid_flex_filter = (left_d3_knuckle_score < scoreThresh) | (left_d3_mid_score < scoreThresh) | (left_d3_tip_score < scoreThresh);
aniposeData_filtered.right_d3_mid_flex(right_d3_mid_flex_filter) = nan;

% left_d4_mid_flex
left_d4_mid_flex_filter = (left_d4_knuckle_score < scoreThresh) | (left_d4_mid_score < scoreThresh) | (left_d4_tip_score < scoreThresh);
aniposeData_filtered.left_d4_mid_flex(left_d4_mid_flex_filter) = nan;

% left_d5_mid_flex
left_d5_mid_flex_filter = (left_d5_knuckle_score < scoreThresh) | (left_d5_mid_score < scoreThresh) | (left_d5_tip_score < scoreThresh);
aniposeData_filtered.left_d5_mid_flex(left_d5_mid_flex_filter) = nan;

% left_wrist_axis
left_wrist_axis_filter = (left_wrist_score < scoreThresh) | (left_d3_knuckle_score < scoreThresh) | (left_d4_knuckle_score < scoreThresh);
aniposeData_filtered.left_wrist_axis(left_wrist_axis_filter) = nan;

