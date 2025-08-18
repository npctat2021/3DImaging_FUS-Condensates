%% step5: Find the displacement between top and bottom channel based on the spots which are picked in both channels
function Step5_displacement
clear
%% Input Parameters
fold_name='/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';
file_name='Test_SiMRoD';

%%
fd_top=load([fold_name file_name 'overall_top2.txt']);
frame_top=fd_top(:,1);
fd_bottom=load([fold_name file_name 'overall_bottom2.txt']);
frame_bottom=fd_bottom(:,1);
[val_top,pos_top]=intersect(frame_top,frame_bottom);
top_sel=fd_top(pos_top,:); %top spot details which are common with bottom
[val_bottom,pos_bottom]=intersect(frame_bottom,frame_top);
bottom_sel=fd_bottom(pos_bottom,:); %bottom spot details which are common with top

%%%calculate the displacement from only those spots that have at least 40% of the maximum photon count in BOTH channels
top_photon=top_sel(:,8);
bottom_photon=bottom_sel(:,8);

% Find maximum photon counts in each channel
max_top = max(top_photon);
max_bottom = max(bottom_photon);

% Create logical indices for spots with at least 40% of max intensity in both channels
ind_high_photon = (top_photon > 0.4*max_top) & (bottom_photon > 0.4*max_bottom);

% Select only high photon spots from both channels
top_high_photon = top_sel(ind_high_photon,:);
bottom_high_photon = bottom_sel(ind_high_photon,:);

% Calculate displacement
top_high_photon_x=top_high_photon(:,2);
bottom_high_photon_x=bottom_high_photon(:,2);
diff_x=bottom_high_photon_x-top_high_photon_x;
mean_diff_x=mean(diff_x);

top_high_photon_y=top_high_photon(:,5);
bottom_high_photon_y=bottom_high_photon(:,5);
diff_y=bottom_high_photon_y-top_high_photon_y;
mean_diff_y=mean(diff_y);

displaced=[mean_diff_x,mean_diff_y];
save([fold_name file_name 'displace.txt'],'-ascii','-TABS','displaced');
end