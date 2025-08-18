function Jump_step_histogram_fitter_2D

lb = [0.00, 0, 0];  %lower bound
ub = [0.02, 1, 1];  %upper bound
 
[x,fval] = ga(@Diff_coeff_2, 3, [],[],[],[], lb, ub);

%% Global Optimization fitting routine
function f = Diff_coeff_2(x)

dc_1 = round(x(1,1),2);
dc_2 = round(x(1,2),2);
a = round(x(1,3),2);

exp_data = readmatrix("Experiment.xlsx"); % Input Experimental Data filename
first_loc = load('First_Localization.mat');

%% Standard Localization Parameters
mean_photons = 6.86;
sd_photons = 0.187;
min_photons = 500;
x_range = 2000;
y_range = 2000;
z_range = 500; % Total range of Z

%% Enter Acquisition Parameters
time = 5; %(Enter in ms)
camera = 2; %input('Do you want to simulate for Prime95B (1) or Kinetix22 (2) ?: ');
loc_number = 100000; % Number of points used to build the jumpstep histogram

%% Standard Camera Parameters
if camera == 1
    mean_camera = 7.52;
    sd_camera = 0.426;
    calibration_photons = 3000;
    sigma_camera_x = 4.19;
    c_x = 325;
    d_x = 338;
    C_x = -1.17;
    D_x = 0.708;

    sigma_camera_y = 3.59;
    c_y = -346;
    d_y = 399;
    C_y = -0.358;
    D_y = 0.382;

    E = 1.32;
    offset = 0; 
else
    mean_camera = 7.745;
    sd_camera = 0.530;
    calibration_photons = 3000;

    sigma_camera_x = 3.9;
    c_x = -730.52;
    d_x = 666.36;
    C_x = 0.451;
    D_x = 1.052;

    sigma_camera_y = 4.95;
    c_y = 710;
    d_y = 650;
    C_y = 0.03;
    D_y = 0.4;

    E = 1.05;
    offset = 0; 
end

%% Loading First Localization Info
x_loc1 = first_loc.all_data(:,2);
y_loc1 = first_loc.all_data(:,3);
z_loc1 = first_loc.all_data(:,4);
x1 = first_loc.all_data(:,8);
y1 = first_loc.all_data(:,9);
z1 = first_loc.all_data(:,10);

%% Adding second localization
for j= 1:1:loc_number
    photons_loc2(j,1)= exp(mean_photons + sd_photons*norminv(normcdf((log(min_photons)-mean_photons)/sd_photons,0,1) ...
        + (1-normcdf(((log(min_photons)-mean_photons)/sd_photons),0,1))*rand(),0,1)); %Random distrubution of photons above mentioned threshold
    rand_nm(j,1) = rand();
    
    if rand_nm(j,1) <= a 
        sigma_df = (2*(10^6)*dc_1*(time/1000))^0.5; %Adding jumps from diff coeff
        x_loc2(j,1)= x_loc1(j,1) + norminv(rand(),0,sigma_df);
        y_loc2(j,1)= y_loc1(j,1) + norminv(rand(),0,sigma_df);
        z_loc2(j,1)= z_loc1(j,1) + norminv(rand(),0,sigma_df);
    
        %Generating precison values
        x_eq2 = (z_loc2(j,1)+c_x)/d_x;
        x_precision2(j,1) = ((calibration_photons/photons_loc2(j,1))^0.5)*(sigma_camera_x*(1+(x_eq2)^2 ...
            +C_x*(x_eq2)^3 + D_x*(x_eq2)^4)^0.5);
        y_eq2 = (z_loc2(j,1)+c_y)/d_y;
        y_precision2(j,1) = ((calibration_photons/photons_loc2(j,1))^0.5)*(sigma_camera_y*(1+(y_eq2)^2 ...
            +C_y*(y_eq2)^3 + D_y*(y_eq2)^4)^0.5);
        z_eq_x2 = (z_loc2(j,1)+c_x-offset)/d_x;
        z_eq_y2 = (z_loc2(j,1)+c_y-offset)/d_y;
        z_precision2(j,1) = ((calibration_photons/photons_loc2(j,1))^0.5)*(E*(((sigma_camera_x*(1+(z_eq_x2)^2+C_x*(z_eq_x2)^3 + D_x*(z_eq_x2)^4)^0.5)^2 ...
            + (sigma_camera_y*(1 + (z_eq_y2)^2 +C_y*(z_eq_y2)^3 + D_y*(z_eq_y2)^4)^0.5)^2)^0.5));
    
        %Adding precision
        x2(j,1) = norminv(rand(),x_loc2(j,1),x_precision2(j,1));
        y2(j,1) = norminv(rand(),y_loc2(j,1),y_precision2(j,1));
        z2(j,1) = norminv(rand(),z_loc2(j,1),z_precision2(j,1));

    else
        sigma_df = (2*(10^6)*dc_2*(time/1000))^0.5; %Adding jumps from diff coeff
        x_loc2(j,1)= x_loc1(j,1) + norminv(rand(),0,sigma_df);
        y_loc2(j,1)= y_loc1(j,1) + norminv(rand(),0,sigma_df);
        z_loc2(j,1)= z_loc1(j,1) + norminv(rand(),0,sigma_df);
    
        %Generating precison values
        x_eq2 = (z_loc2(j,1)+c_x)/d_x;
        x_precision2(j,1) = ((calibration_photons/photons_loc2(j,1))^0.5)*(sigma_camera_x*(1+(x_eq2)^2 ...
            +C_x*(x_eq2)^3 + D_x*(x_eq2)^4)^0.5);
        y_eq2 = (z_loc2(j,1)+c_y)/d_y;
        y_precision2(j,1) = ((calibration_photons/photons_loc2(j,1))^0.5)*(sigma_camera_y*(1+(y_eq2)^2 ...
            +C_y*(y_eq2)^3 + D_y*(y_eq2)^4)^0.5);
        z_eq_x2 = (z_loc2(j,1)+c_x-offset)/d_x;
        z_eq_y2 = (z_loc2(j,1)+c_y-offset)/d_y;
        z_precision2(j,1) = ((calibration_photons/photons_loc2(j,1))^0.5)*(E*(((sigma_camera_x*(1+(z_eq_x2)^2+C_x*(z_eq_x2)^3 + D_x*(z_eq_x2)^4)^0.5)^2 ...
            + (sigma_camera_y*(1 + (z_eq_y2)^2 +C_y*(z_eq_y2)^3 + D_y*(z_eq_y2)^4)^0.5)^2)^0.5));
    
        %Adding precision
        x2(j,1) = norminv(rand(),x_loc2(j,1),x_precision2(j,1));
        y2(j,1) = norminv(rand(),y_loc2(j,1),y_precision2(j,1));
        z2(j,1) = norminv(rand(),z_loc2(j,1),z_precision2(j,1));
    end

    % Jump histograms
    jump(j,1) = sqrt((x2(j,1)- x1(j,1))^2 + (y2(j,1)- y1(j,1))^2 + (z2(j,1)- z1(j,1))^2);
end

%% Calculating the fit
edges = 0:0.01:0.60;
h1 = histcounts(jump/1000, edges, 'Normalization', 'probability');
f = sum((exp_data(1:60,2)- h1').^2);
dc_1, dc_2

end
save("Jump_step_histogram_fitter_2D.mat","x",'-mat');
end

