% After running the script in MATLAB, an image will open in a figure window. Select points around the desired region by left-clicking on the image 
% to mark multiple points that define the shape of the ellipse. The selected points will appear as red circles. Once you have marked all the points 
% for a particular region, right-click or press Enter to finish the selection, and the program will automatically fit an ellipse through the points 
% and display it on the image. To select another ellipse, click more points around the next region, finish the selection with a right-click or Enter, 
% and repeat the process as many times as needed. After all ellipses are selected, close the figure window.

function Step3_circular_roi
clc;
clear;

%% === Input parameters ===
p = 2;  % 1 for top, 2 for bottom
fold_name = '/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';  % <=== Update if needed
file_name1 = 'Scatter plot';  % Brightfield/visualization image
file_name2 = 'Test_SiMRoD';        % Raw data file name

%% === Load image and data ===
img = double(imread([fold_name file_name1 '.tif']));
if p == 1
    overall_2 = load([fold_name file_name2 'overall_top.txt']);
else
    overall_2 = load([fold_name file_name2 'overall_bottom.txt']);
end

% Extract columns
frame_sorted   = overall_2(:,1);
xx_sorted      = overall_2(:,2);
xxnm_sorted    = overall_2(:,3);
xwidth_sorted  = overall_2(:,4);
yy_sorted      = overall_2(:,5);
yynm_sorted    = overall_2(:,6);
ywidth_sorted  = overall_2(:,7);
photon_sorted  = overall_2(:,8);

roi_all_combine = [];

disp('Left-click multiple points to define ellipse. Right-click or press Enter to finish.');

imshow(img, [], 'InitialMagnification', 'fit');

if p == 1
    title('Select ellipse from TOP channel. Right-click/Enter to fit.', 'FontSize', 12);
else
    title('Select ellipse from BOTTOM channel. Right-click/Enter to fit.', 'FontSize', 12);
end

hold on;

while true

    [xp, yp, bt] = ginput;
    if isempty(xp)
        break;  % user ended selection
    end

    % --- Plot the selected points as circles ---
    plot(xp, yp, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);

    % Fit ellipse to selected points
    try
        ellipse_t = fit_ellipse(xp, yp);
theta = linspace(0, 2*pi, 300);
ellipse_x = ellipse_t.X0_in + ellipse_t.a * cos(theta) * cos(ellipse_t.phi) - ellipse_t.b * sin(theta) * sin(ellipse_t.phi);
ellipse_y = ellipse_t.Y0_in + ellipse_t.a * cos(theta) * sin(ellipse_t.phi) + ellipse_t.b * sin(theta) * cos(ellipse_t.phi);

hold on;
plot(ellipse_x, ellipse_y, 'r-', 'LineWidth', 1.5);

        % Find points inside the fitted ellipse
        X = xx_sorted - ellipse_t.X0_in;
        Y = yy_sorted - ellipse_t.Y0_in;
        cos_phi = cos(ellipse_t.phi);
        sin_phi = sin(ellipse_t.phi);
        X_rot = X * cos_phi + Y * sin_phi;
        Y_rot = -X * sin_phi + Y * cos_phi;
        idx_inside = (X_rot / ellipse_t.a).^2 + (Y_rot / ellipse_t.b).^2 <= 1;

        roi_all = [frame_sorted(idx_inside), xx_sorted(idx_inside), xxnm_sorted(idx_inside), ...
                   xwidth_sorted(idx_inside), yy_sorted(idx_inside), yynm_sorted(idx_inside), ...
                   ywidth_sorted(idx_inside), photon_sorted(idx_inside)];

        roi_all_combine = [roi_all_combine; roi_all];
    catch
        disp('Ellipse fitting failed. Please try again.');
    end
    pause(1);
end

% Remove duplicate rows
[Mu, ia, ic] = unique(roi_all_combine, 'rows');

% Save final result
if p == 1
    save([fold_name file_name2 'overall_top2.txt'], '-ascii', '-tabs', 'Mu');
else
    save([fold_name file_name2 'overall_bottom2.txt'], '-ascii', '-tabs', 'Mu');
end

disp('ROI data saved successfully.');
end
