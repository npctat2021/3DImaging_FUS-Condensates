# 3DImaging_FUS-Condensates
MATLAB scripts to analyze properties of biomolecular condensates. 

This repository contains three separate folders dedicated to different single-molecule measurements made in this paper:  

 - **Droplet density maps**
 - **3D-astigmatism Tracking**
 - **SiMRoD (Single-molecule rotational diffusion microscopy) Analysis**

Each folder contains a readme.md file with instructions on  
- How to run the scripts
- Data format required to run them 
- The order in which they need to be run
  
## System Requirements
MATLAB 2021b and newer. with toolboxes:
- Statistics and Machine Learning
- Global Optimization
- Signal Processing
- Optimization
- Image Processing
- Curve Fitting

The majority of the scripts don't require high computational power or special hardware. It should work even with a laptop PC with an OKish CPU and RAM. It was developed with the Windows system, but should also work on other OS with MATLAB and toolboxes readily installed. Typical install time on a "normal" desktop computer is 30-45 minutes. 

 - **3D-astigmatism Tracking** -> Diff_Coeff_Fit_3.mat requires moderate computational power, and the run time on a 64 GB RAM Dell Precision 5820 computer with Intel® Core™ i9-10900X is ~4 h. 
