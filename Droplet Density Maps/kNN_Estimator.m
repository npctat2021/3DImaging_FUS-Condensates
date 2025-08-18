function kNN_Estimator
%This script is used to calculate the epsilon value required to run the DBSCAN program.

data = readmatrix("Test_Sim2.csv");
data_xy = [data(:,3)/1000, data(:,4)/1000, data(:,5)/1000];
minNumPoints = 2;
maxNumPoints = 5;

clusterDBSCAN.estimateEpsilon(data_xy,minNumPoints,maxNumPoints)

end