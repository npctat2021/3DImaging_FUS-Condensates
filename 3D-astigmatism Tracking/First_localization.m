function First_localization

%% Standard Localization Parameters from the experimental Dataset
mean_photons = 6.86; 
sd_photons = 0.187; %std deviation
min_photons = 500; %Minimum photons used to collect tracks
x_range = 4000; 
y_range = 4000;
z_range = 500; % Total range of Z used to collect tracks

%% Enter Diffusion Coefficients
time = 5; % In ms
camera = 2; % input ('Do you want to simulate for Prime95B (1) or Kinetix22 (2) ?: ');
loc_number = 100000; %input('Enter the number of points required: ');

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

%% Adding first Localization
for i=1:loc_number
    photons_loc1(i,1)= exp(mean_photons + sd_photons*norminv(normcdf((log(min_photons)-mean_photons)/sd_photons,0,1)...
        + (1-normcdf(((log(min_photons)-mean_photons)/sd_photons),0,1))*rand(),0,1)); %Random distrubution of photons above mentioned threshold
    
    %x,y,z localizations within specified ranges
    x_loc1(i,1) = x_range*(rand - 0.5);
    y_loc1(i,1) = y_range*(rand - 0.5);
    z_loc1(i,1) = z_range*(rand - 0.5);
    
    %Generating precison values
    x_eq = (z_loc1(i,1)+c_x)/d_x;
    x_precision(i,1) = ((calibration_photons/photons_loc1(i,1))^0.5)*(sigma_camera_x*(1+(x_eq)^2 ...
        +C_x*(x_eq)^3 + D_x*(x_eq)^4)^0.5);
    y_eq = (z_loc1(i,1)+c_y)/d_y;
    y_precision(i,1) = ((calibration_photons/photons_loc1(i,1))^0.5)*(sigma_camera_y*(1+(y_eq)^2 ...
        +C_y*(y_eq)^3 + D_y*(y_eq)^4)^0.5);
    z_eq_x = (z_loc1(i,1)+c_x-offset)/d_x;
    z_eq_y = (z_loc1(i,1)+c_y-offset)/d_y;
    z_precision(i,1) = ((calibration_photons/photons_loc1(i,1))^0.5)*E*(((sigma_camera_x*(1+(z_eq_x)^2+C_x*(z_eq_x)^3 + D_x*(z_eq_x)^4)^0.5)^2 ...
        + (sigma_camera_y*(1 + (z_eq_y)^2 +C_y*(z_eq_y)^3 + D_y*(z_eq_y)^4)^0.5)^2)^0.5);
    
    %Adding precision
    x1(i,1) = norminv(rand(),x_loc1(i,1),x_precision(i,1));
    y1(i,1) = norminv(rand(),y_loc1(i,1),y_precision(i,1));
    z1(i,1) = norminv(rand(),z_loc1(i,1),z_precision(i,1));
end

all_data = [photons_loc1,  x_loc1, y_loc1, z_loc1, x_precision, y_precision, z_precision, x1, y1, z1];

save('First_Loc.mat', "all_data");