# 3D-astigmatism Tracking
MATLAB script to fit the jump step histogram. Run the programs in the following order:

## 1. First_localization.mat
This MATLAB script generates random localizations in 3D space depending on the input parameters. Parameters that are involved:
- Minimum photons used for tracking experiments
- Center of the log-normal photon distribution
- Z range of the experiment
- Astigmatism parameters (described in [Chowdhury et al., Optics Letters 2022:](https://opg.optica.org/ol/abstract.cfm?uri=ol-47-21-5727))

## 2. Jump Step Histogram Fitter
This MATLAB script generates a second localization corresponding to each localization generated in the first MATLAB script, depending on the input diffusion coefficient parameters. It then generates a jump histogram and compares it to the experimental jump histogram using RMSD. The program involves a global optimization algorithm that generates new jump histograms for different diffusion coefficient values, and the output is the value that yields the lowest RMSD. There are three versions of this file:

### a. Jump_step_histogram_fitter_1D.mat
This file fits the experimental jump histogram to a single diffusion coefficient.
Variables and output from this file:
- D (Diffusion coefficient)

### b. Jump_step_histogram_fitter_2D.mat
This file fits the experimental jump histogram to two diffusion coefficients.
Variables and output from this file:
- D1(Diffusion coefficient of species 1)
- D2(Diffusion coefficient of species 2)
- A1 (Fraction of species 1)

### c. Jump_step_histogram_fitter_3D.mat
This file fits the experimental jump histogram to three diffusion coefficients.
Variables and output from this file:
- D1(Diffusion coefficient of species 1)
- D2(Diffusion coefficient of species 2)
- D3(Diffusion coefficient of species 3)
- A1(Fraction of species 1)
- A2(Fraction of species 2)

To plot/visualize the best fit on the experimental data set, we input the values generated here into the "Jump Step Histogram Simulator2.xlsx" file on figshare. The values obtained in the Excel file represent the simulated data that best fit the experimental data set.  

