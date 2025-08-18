%% step-7: It will merge bottom2_sorted and top2_added and include missing points from bottom2_added and top2_sorted
function Step7_include_missingpoints
clc
clear
%% Input Parameters
fold_name='/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';
file_name='Test_SiMRoD';

%%
top_init_pts=load([fold_name file_name 'overall_top2_added' '.txt']);
bottom_init_pts=load([fold_name file_name 'overall_bottom3_sorted' '.txt']);
top_tobe_added_from=load([fold_name file_name 'overall_top3_sorted' '.txt']);
bottom_tobe_added_from=load([fold_name file_name 'overall_bottom2_added' '.txt']);
fr_top_init_pts=top_init_pts(:,1);
fr_top_tobe_added_from=top_tobe_added_from(:,1);
[fr_top_unique,fr_top_unique_indices]=setdiff(fr_top_tobe_added_from,fr_top_init_pts);
top_tobe_added=top_tobe_added_from(fr_top_unique_indices,:);
bottom_tobe_added=bottom_tobe_added_from(fr_top_unique_indices,:);
top_combined=[top_init_pts;top_tobe_added];
top_combined2=sortrows(top_combined,1);
bottom_combined=[bottom_init_pts;bottom_tobe_added];
bottom_combined2=sortrows(bottom_combined,1);
save([fold_name file_name 'overall_top2_combined.txt'],'-ascii','-TABS','top_combined2');
save([fold_name file_name 'overall_bottom2_combined.txt'],'-ascii','-TABS','bottom_combined2');
end