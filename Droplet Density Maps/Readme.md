# Scripts to create Droplet Density Maps
Three MATLAB scripts are required to generate maps:
1. Cube_Volume_Estimator.mat
2. kNN_Estimator.mat
3. DBSCAN.mat

## 1. Cube_Volume_Estimator.mat
This script is used to calculate the 3D volume of a condensate. 

## Description:
The condensate is divided into multiple smaller cubes of specified dimensions. Then, the number of localizations within each smaller cube is determined by the program. This is then followed by calculating the number of cubes with at least one localization. Finally, it sums up the volume of all cubes that have localization > 0 to yield the final volume of the condensate. 

## Instructions for use
The script takes the following variables:
- Size of the big cube (this should engulf the whole condensate)
- Length of smaller cubes (this defines the size of the smaller cubes)

## Output
Results.mat file will be generated with the output. 

## 2. kNN_Estimator.mat
This script is used to calculate the epsilon value required to run the DBSCAN program. 

## Description:
The kNN program estimates the knee of the k-nearest neighbors (kNN) curve. This is the point on the kNN curve closest to the point at which the curve’s asymptotes intersect. [More information about the program can be found here:](https://www.mathworks.com/help/radar/ref/clusterdbscan.clusterdbscan.estimateepsilon.html)  

## Instructions for use
The kNN program is run on the simulated data file. There are 2 variables:
- Minimum points (value used was 2)
- Maximum points (value used was 5)

## Output
A plot displaying the correct epsilon value will be generated. Users can save the plot if required. 

## 3. DBSCAN.mat
This script is used to visualize clusters within condensates.  

## Description:
The DBSCAN algorithm calculates the number of neighbors for each localization and isolates clusters from within the condensates.. [More information about the program can be found here:](https://www.mathworks.com/help/stats/dbscan.html)  

## Instructions for use
- First, run the DBSCAN program on the simulated data file. There are two variables:
  - Epsilon: Input value obtained from "kNN.mat"
  - Minimum number of points
    - This is the value at which DBSCAN does not recognize any high-density points in the simulated data set. The value set here should yield       no clusters when run on the simulated data file.
- Now, using the same "kNN value" and "Minimum number of points" obtained while running the simulated data file run the experimental data file.

## Output
An image of all dense regions within the condensate will be displayed. 
