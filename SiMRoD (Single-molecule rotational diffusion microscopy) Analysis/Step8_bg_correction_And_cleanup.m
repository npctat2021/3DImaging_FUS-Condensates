%% Merged Steps 8: Background Correction and Spot Filtering
function Step8_bg_correction_And_cleanup
clc
clear

%% Input Parameters
len = 30563; % Total number of frames
bg_frames = 10; % Number of frames for background
quantum_yield = 1;
r = 6;
fold_name = '/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';
file_name = 'Test_SiMRoD';

%% Step 10: Background Correction - Top Channel
disp('Step 10: Top Channel Background Correction...');
spot_details_top = load([fold_name file_name 'overall_all2.txt']);
frame_sorted = spot_details_top(:,1);
x_sorted = spot_details_top(:,2);
y_sorted = spot_details_top(:,5);
int_sorted = spot_details_top(:,8);

frames_total = (len-bg_frames:len)';
fr = [];
for p = 1:length(frames_total)
    if ~ismember(frames_total(p), frame_sorted)
        fr = [fr; frames_total(p)];
    end
end
% Save for later use (for Step 11)
save([fold_name file_name 'fr.txt'], '-ascii', '-TABS', 'fr');

spot_selected_top = load([fold_name file_name 'overall_top2_combined.txt']);
frame_selected_top = spot_selected_top(:,1);
x_selected_top = spot_selected_top(:,2);
y_selected_top = spot_selected_top(:,5);
int_selected_top = spot_selected_top(:,8);

int_avg_top = zeros(size(int_selected_top));
for s = 1:length(frame_selected_top)
    sx = ceil(x_selected_top(s));
    sy = ceil(y_selected_top(s));
    int = [];
    for t = 1:length(fr)
        img = double(imread([fold_name file_name '.tif'], fr(t)));
        int1 = sum(sum(img(sy-r:sy+r, sx-r:sx+r))) / quantum_yield;
        int = [int; int1];
    end
    int_avg_top(s) = mean(int);
end
int_corr_top = int_selected_top - int_avg_top;
spot_details_bg_top = [spot_selected_top, int_avg_top, int_corr_top];
save([fold_name file_name 'spot_details_bg_top.txt'], '-ascii', '-TABS', 'spot_details_bg_top');

%% Step 11: Background Correction - Bottom Channel
disp('Step 11: Bottom Channel Background Correction...');
spot_selected_bottom = load([fold_name file_name 'overall_bottom2_combined.txt']);
fr = load([fold_name file_name 'fr.txt']);

frame_selected_bottom = spot_selected_bottom(:,1);
x_selected_bottom = spot_selected_bottom(:,2);
y_selected_bottom = spot_selected_bottom(:,5);
int_selected_bottom = spot_selected_bottom(:,8);

int_avg_bottom = zeros(size(int_selected_bottom));
for s = 1:length(frame_selected_bottom)
    sx = ceil(x_selected_bottom(s));
    sy = ceil(y_selected_bottom(s));
    int = [];
    for t = 1:length(fr)
        img = double(imread([fold_name file_name '.tif'], fr(t)));
        int1 = sum(sum(img(sy-r:sy+r, sx-r:sx+r))) / quantum_yield;
        int = [int; int1];
    end
    int_avg_bottom(s) = mean(int);
end
int_corr_bottom = int_selected_bottom - int_avg_bottom;
spot_details_bg_bottom = [spot_selected_bottom, int_avg_bottom, int_corr_bottom];
save([fold_name file_name 'spot_details_bg_bottom.txt'], '-ascii', '-TABS', 'spot_details_bg_bottom');

%% Step 12: Eliminate Dim Spots
disp('Step 12: Eliminate Dim Spots...');
spot_details_top = spot_details_bg_top;
spot_details_bottom = spot_details_bg_bottom;

row_from_top = spot_details_top(:,10) > 0;
step1_top = spot_details_top(row_from_top,:);
step1_bottom = spot_details_bottom(row_from_top,:);

row_from_bottom = step1_bottom(:,10) > 0;
step2_top = step1_top(row_from_bottom,:);
step2_bottom = step1_bottom(row_from_bottom,:);

save([fold_name file_name ' top_intensed.txt'],'-ascii','-TABS','step2_top');
save([fold_name file_name ' bottom_intensed.txt'],'-ascii','-TABS','step2_bottom');

% Keep spots with at least 200 photons in one channel
spot_details_top_final = [];
spot_details_bottom_final = [];
rejected_spots = [];

for i = 1:size(step2_bottom,1)
    if step2_top(i,10) > 200 || step2_bottom(i,10) > 200
        spot_details_top_final = [spot_details_top_final; step2_top(i,:)];
        spot_details_bottom_final = [spot_details_bottom_final; step2_bottom(i,:)];
    else
        rejected_spots = [rejected_spots; step2_top(i,:), step2_bottom(i,10)];
    end
end

save([fold_name file_name ' top_intensed2.txt'],'-ascii','-TABS','spot_details_top_final');
save([fold_name file_name ' bottom_intensed2.txt'],'-ascii','-TABS','spot_details_bottom_final');

disp('All steps completed successfully!');
