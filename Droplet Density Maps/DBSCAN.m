function DBSCAN
%This script is used to identify and visualize clusters within condensates.

%% Variables
data = readmatrix("Test_Exp.csv"); % Change to "Test_Exp.xlsx" to run it on experimental dataset
epsilon = 0.074; % In um
min_points = 22; % Minimum points within the epsilon for a localization to be considered as part of the cluster

%% Density Calculation
data_xy = [data(:,3)/1000, data(:,4)/1000, data(:,5)/1000];

figure(7)
[idx,corepts] = dbscan(data_xy, epsilon, min_points);
output = [idx,corepts];
result = [data idx corepts];
result_clusters = result(result(:, 13) > 0, :);

scatter3(result_clusters(:,3), result_clusters(:,4), result_clusters(:,5), 5, result_clusters(:,13), 'filled');
colormap("hsv")

writematrix(output, "dbscan_Exp.xlsx")
writematrix(result_clusters, "All clusters.xlsx")

end