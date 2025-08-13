# Scripts to Analyze SiMRoD Data
14 MATLAB scripts need to be run in the following order to analyze data. 

## Step1_SpotFitting_And_Cleanup.mat
This script is used to localize all spots in the movie and eliminate spots that are close to one another.

### Special Instructions: 
- Change these variables (lines 10-14) in the script accordingly- 
  - len = 30514;                        (Number of frames to process)
  - pixel_size = 138;                   (in nm)
  - r = 6;                              (Fitting radius)
  - minimum_photons = 30;               (Minimum intensity threshold)
  - quantum_yield = 1;                  (This is for the camera. Set to 1 if pixel values are already in photons)

 - Make sure the video is in '.tif' format

## Step2_top_bottom_separate.mat
This script separates localizations obtained in the p- and s- channels into two separate files. 

### Special Instructions: 
- Change these variables (lines 10) in the script accordingly- 
  - cutoff = 135; (Input the y-pixel value that approximately separates the top and bottom polarization channels in the camera; The cutoff value is an approximation and the true value is later estimated in Step5)

## Step3_circular_roi.mat
This script is used to select the condensate that needs to be analyzed.

### Special Instructions: 
- Change these variables (lines 12) in the script accordingly- 
  - p = 1;  (1 for top channel, 2 for bottom channel). You need to run the script twice: once for the top channel with p = 1 and again for the bottom channel with p = 2.
 
- How to select an ROI?
  - Input p = 1 or 2 accordingly
  - In the window that pops up, start clicking around the condensate in the top channel (if p = 1) or the condensate in the bottom channel (if p = 2). Select points all the way around the condensate.
  - Once done, press enter or right click
  - You should see the "ROI data saved successfully" message appear in the command window

## Step4_eliminate_repeated_spots.mat
This script can be used to remove localizations that appear in successive frames. It was set to 0 for our experiments to collect all localizations. 

### Special Instructions: 
numFramesToConsider = 0; % Number of frames each spot lasts during acquisition
xThreshold = 20; % Threshold in nm
yThreshold = 20; % Threshold in nm

## Step5_displacement.mat
This script determines the displacement between the top and the bottom channels. These values are used for channel alignment later on. Here, the localizations that appear in both channels are chosen. To make the displacement calculations as accurate as possible, we select localizations that have enough photons in both channels (40% of the maximum in their respective channels). 

## Step6_detect_spots_dual_channel_revised.mat
This script uses localization information in the bottom channel to fit spots in the top channel. Similarly, it then uses localization information in the 
top channel to fit spots in the bottom channel.

### Special Instructions: 
- Change these variables (lines 10) in the script accordingly (all these values should be the SAME as what was used in "Step1_SpotFitting_And_Cleanup.mat"-
  - quantum_yield = 1; (Quantum yield or Camera ADC)
  - pixel_size = 138;  (in nm)
  - r = 6;             (Fitting radius)

## Step7_include_missingpoints.mat
Includes any points that are missed in Step6. 

## Step8_bg_correction_And_cleanup.mat
This script subtracts the background from the spot intensity to yield the true intensity of photons. 

### Special Instructions: 
- Change these variables (lines 7-10) in the script accordingly (all these values should be the SAME as what was used in "Step1_SpotFitting_And_Cleanup.mat"-
  - len = 30514; 
  - bg_frames = 10; (Number of frames for background)
  - quantum_yield = 1;
  - r = 6;

## Step9_Combined_Photon_and_Polarization_Analysis
This script compares the intensity difference between the spots localized in both channels and computes a 'Var(p)'. 
'p_statistics.txt' has the result in this order: g value used, average p value (should be close to 0), average p2 value [Var(p) = average p2 value - average p value)] 

### Special Instructions: 
- Change this variable (line 8) in the script accordingly
  - g = 0.98; (Adjust g-factor for optimal overlap between the photon distribution curves from localizations in p- and s-channel)
