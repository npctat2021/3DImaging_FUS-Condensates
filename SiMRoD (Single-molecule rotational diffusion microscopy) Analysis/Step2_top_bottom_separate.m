%% step2: Separates localizations in top and bottom channel into two separate files for further analysis. 

function Step2_top_bottom_separate
clc
clear
%% Input parameters
fold_name='/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';
file_name='Test_SiMRoD';
fd=load([fold_name file_name 'overall_all2.txt']);
cutoff = 135; % Input the y-pixel value that approximately separates the top and bottom polarization channels in the camera

%%
frame=fd(:,1);
y=fd(:,5);
overall_top=[];
overall_bottom=[];
for p=1:1:length(frame)
    if y(p) < cutoff 
        top1=fd(p,:);
        overall_top=[overall_top;top1];
    else
        bottom1=fd(p,:);
        overall_bottom=[overall_bottom;bottom1];
    end
end
overall_top;
overall_bottom;
save([fold_name file_name 'overall_top.txt'],'-ascii','-TABS','overall_top');
save([fold_name file_name 'overall_bottom.txt'],'-ascii','-TABS','overall_bottom');
end