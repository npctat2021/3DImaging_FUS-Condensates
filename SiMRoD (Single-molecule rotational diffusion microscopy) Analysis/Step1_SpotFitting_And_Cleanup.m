function Step1_SpotFitting_And_Cleanup
% This script fits all spots in the .tif video file using the variables 
% described  below. To visualize fits, you can turn on "Visualization Block"
% from lines 47-64 by removing the % sign. 

clc
%% === Input Information ===    
fold_name = '/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';  % <<== UPDATE this path
file_name = 'Test_SiMRoD';              % .tif filename and output prefix
len = 30563;                       % Number of frames to process
pixel_size = 138;                  % in nm
r = 6;                             % Fitting radius
minimum_photons = 30;             % Minimum intensity threshold
quantum_yield = 1;                % This is for the camera. Set to 1 if pixel values are already in photons

%% === STEP 1: Spot Fitting ===
spot_details = [];
for i = 1:len
    img = double(imread([fold_name file_name '.tif'], i));
    imgr = img;
    [peak_num, xp1, yp1] = multi_spot_finding(imgr, r, minimum_photons);
    
    b = []; x_width = []; y_width = [];
    xx = []; yy = []; xx_nm = []; yy_nm = []; photon_c = [];
    
    if peak_num > 0
        for t = 1:peak_num
            xp = xp1(t); yp = yp1(t);
            ps = double(imgr(yp:yp+2*r, xp:xp+2*r));
            bs = imgr(1:2*r+1, 1:2*r+1);
            p = gau_fitting(ps, bs, r);
            xx1 = xp + p(3) - 1;
            yy1 = yp + p(4) - 1;
            xx1nm = xx1 * pixel_size;
            yy1nm = yy1 * pixel_size;
            x_width1 = pixel_size * p(5);
            y_width1 = pixel_size * p(6);
            photon_c1 = sum(sum(ps)) / quantum_yield;

            b = [b; i];
            xx = [xx; xx1]; yy = [yy; yy1];
            xx_nm = [xx_nm; xx1nm]; yy_nm = [yy_nm; yy1nm];
            x_width = [x_width; x_width1]; y_width = [y_width; y_width1];
            photon_c = [photon_c; photon_c1];

            % === Optional: Visualization Block ===
%             s = 1:2*r+1;
%             intd = zeros(1, length(s));
%             for l = 1:length(s)
%                 intd(l) = ps(l,l);
%             end
%             s1 = 1:0.1:2*r+1;
%             intf = p(1) + p(2) * exp(-(s1 - p(3)).^2 / (2 * p(5)^2) - (s1 - p(4)).^2 / (2 * p(6)^2));
% 
%             figure(1);
%             subplot(1,2,1);
%             imshow(imgr, 'DisplayRange', [min(imgr(:)) max(imgr(:))], 'InitialMagnification', 'fit');
%             hold on;
%             plot(xx1, yy1, 'r*');
%             title(['Movie Frame ' num2str(i)]);
%             subplot(1,2,2);
%             plot(s, intd, 'r*', s1, intf, 'b-');
%             pause(2);
%             clf(figure(1)); % clear figure for next spot
            %%%%%
        end
        spot_details2 = [b, xx, xx_nm, x_width, yy, yy_nm, y_width, photon_c];
        spot_details = [spot_details; spot_details2];
    end
end

save([fold_name file_name 'overall_all.txt'], '-ascii', '-tabs', 'spot_details');

%% === STEP 2: Remove Duplicates Within the Same Frame ===
fd = spot_details;
frame = fd(:,1);
xp = fd(:,2); x_width = fd(:,4);
yp = fd(:,5); y_width = fd(:,7);
photon_c = fd(:,8);
fr_sel = unique(frame);
spot_detail = [];

for m = 1:length(fr_sel)
    mm = fr_sel(m);
    seq_num = find(frame == mm);
    
    frame1 = frame(seq_num); xp1 = xp(seq_num); yp1 = yp(seq_num);
    x_width1 = x_width(seq_num); y_width1 = y_width(seq_num);
    photon_c1 = photon_c(seq_num);
    
    for w = 1:length(frame1)
        ss = xp1(w); sss = yp1(w);
        t2 = find(xp1 - ss < 5 & xp1 - ss > -5 & yp1 - sss < 5 & yp1 - sss > -5);
        tt = find(t2 ~= w);
        ttt = t2(tt);
        frame1(ttt) = 0; xp1(ttt) = 0; yp1(ttt) = 0;
        x_width1(ttt) = 0; y_width1(ttt) = 0; photon_c1(ttt) = 0;
    end
    
    frame2 = frame1(frame1 ~= 0);
    xp2 = xp1(xp1 ~= 0); yp2 = yp1(yp1 ~= 0);
    x_width2 = x_width1(x_width1 ~= 0);
    y_width2 = y_width1(y_width1 ~= 0);
    photon_c2 = photon_c1(photon_c1 ~= 0);
    
    xp2nm = xp2 * pixel_size;
    yp2nm = yp2 * pixel_size;
    
    spot_det = [frame2, xp2, xp2nm, x_width2, yp2, yp2nm, y_width2, photon_c2];
    spot_detail = [spot_detail; spot_det];
end

save([fold_name file_name 'overall_all2.txt'], '-ascii', '-tabs', 'spot_detail');

%% === Supporting Functions ===

function [peak_num, xp1, yp1] = multi_spot_finding(img, r, min_photon)
    [m,n] = size(img);
    imgt = img(r+1:m-r-1, r+1:n-r-1);
    xdim = size(imgt,1); ydim = size(imgt,2);
    int_row = reshape(imgt', 1, []);
    [pks, locs] = findpeaks(int_row);
    peak_details = [pks', locs'];
    peak_intensed = find(peak_details(:,1) > min_photon); 
    peak_sorted = peak_details(peak_intensed,:);
    peak_number = size(peak_sorted,1);
    locs_sorted = peak_sorted(:,2);
    x_ind = mod(locs_sorted-1, ydim);
    y_ind = floor((locs_sorted-1)/ydim);
    
    xp = x_ind; yp = y_ind;
    for w = 1:length(xp)
        if xp(w) ~= 0
            ss = xp(w); sss = yp(w);
            t2 = find(xp - ss < 4 & xp - ss > -4 & yp - sss < 4 & yp - sss > -4);
            tt = find(t2 ~= w); xp(t2(tt)) = 0; yp(t2(tt)) = 0;
        end
    end
    xp1 = xp(xp ~= 0); yp1 = yp(yp ~= 0);
    if length(xp1) == length(yp1)
        peak_num = length(xp1);
    else
        peak_num = 0; xp1 = []; yp1 = [];
    end
end

function x = gau_fitting(ps, bs, r)
    pm = max(max(ps)); bm = mean(mean(bs));
    g0 = [bm, pm - bm, r+1, r+1, 1, 1];
    residual_fun = @(g) sum(sum((gau(g, r) - ps).^2));
    options = optimset('Display','off','MaxIter',1000,'MaxFunEvals',2000,'TolX',1e-10);
    x = fminsearch(residual_fun, g0, options);
end

function f = gau(g, r)
    [x,y] = meshgrid(1:2*r+1);
    f = g(1) + g(2) * exp(-((x - g(3)).^2)/(2 * g(5)^2) - ((y - g(4)).^2)/(2 * g(6)^2));
end

end
