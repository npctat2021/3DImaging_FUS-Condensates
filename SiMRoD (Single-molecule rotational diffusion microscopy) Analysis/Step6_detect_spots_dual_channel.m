function Step6_detect_spots_dual_channel
% detect_spots_dual_channel - automatically processes both top and bottom channels
clc; clear;

% ==== Input Parameters ====
fold_name = '/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/';
file_name = 'Test_SiMRoD';
quantum_yield = 1; % Quantum yield / ADC
pixel_size = 138;  % in nm
r = 6;             % Fitting radius

% Process both channels
process_channel('top');
process_channel('bottom');

    function process_channel(channel)
        % ==== Load Data ====
        displace = load([fold_name file_name 'displace' '.txt']);

        if strcmpi(channel, 'bottom')
            input_sorted_file = [fold_name file_name 'overall_top2_sorted' '.txt'];
            spot_details = load(input_sorted_file);
            x_disp = displace(1);
            y_disp = displace(2);
            output_file = [fold_name file_name 'overall_bottom2_added.txt'];
            output_sorted_file = [fold_name file_name 'overall_top3_sorted' '.txt'];
        elseif strcmpi(channel, 'top')
            input_sorted_file = [fold_name file_name 'overall_bottom2_sorted' '.txt'];
            spot_details = load(input_sorted_file);
            x_disp = -displace(1);
            y_disp = -displace(2);
            output_file = [fold_name file_name 'overall_top2_added.txt'];
            output_sorted_file = [fold_name file_name 'overall_bottom3_sorted' '.txt'];
        else
            error('Invalid channel. Use ''top'' or ''bottom''.');
        end

        % ==== Spot Detection Loop ====
        frame_sorted = spot_details(:,1);
        x_sorted = spot_details(:,2);
        y_sorted = spot_details(:,5);

        valid_idx = []; % To store indices of valid spots
        
        for q = 1:length(frame_sorted)
            frame(q) = frame_sorted(q);
            xxp = ceil(x_sorted(q) + x_disp);
            yyp = ceil(y_sorted(q) + y_disp);

            fcl = xxp - r - 1;
            fch = xxp + r + 1;
            frl = yyp - r - 1;
            frh = yyp + r + 1;

            img = double(imread([fold_name file_name '.tif'], frame(q)));
            imgr = img(frl:frh, fcl:fch);

            [xp, yp, ps] = peak_find(imgr, r);
            bs = imgr(1:2*r+1, 1:2*r+1);
            p = gau_fitting(ps, bs, r);
            
            % Skip spots where p(3) or p(4) are outside 2-11 range
            if p(3) < 2 || p(3) > 11 || p(4) < 2 || p(4) > 11
                continue;
            end
            
            xx1(q) = xp + p(3) - 1;
            yy1(q) = yp + p(4) - 1;
            xx(q) = fcl + xx1(q) - 1;
            yy(q) = frl + yy1(q) - 1;

            xx_nm(q) = xx(q) * pixel_size;
            yy_nm(q) = yy(q) * pixel_size;
            x_width(q) = pixel_size * p(5);
            y_width(q) = pixel_size * p(6);

            photon_c(q) = sum(sum(ps)) / quantum_yield;
            
            valid_idx = [valid_idx; q]; % Track valid spots
        end

        % Save only valid results for the added file
        results = [frame(valid_idx)', xx(valid_idx)', xx_nm(valid_idx)', x_width(valid_idx)', ...
                   yy(valid_idx)', yy_nm(valid_idx)', y_width(valid_idx)', photon_c(valid_idx)'];
        save(output_file, 'results', '-ascii', '-TABS');
        
        % Create and save the corresponding filtered sorted file
        filtered_sorted = spot_details(valid_idx, :);
        save(output_sorted_file, 'filtered_sorted', '-ascii', '-TABS');
        
        disp(['Processing completed for ' channel ' channel. ' num2str(length(valid_idx)) ' valid spots saved.']);
        disp(['Created matching filtered sorted file: ' output_sorted_file]);
    end
end

% ==== Supporting Functions ==== (remain exactly the same as your original)
function [xp, yp, ps] = peak_find(img, r)
[m,n] = size(img);
imgt = img(r+1:m-r-1, r+1:n-r-1);
[pss1, pii] = max(imgt);
[pss2, piii] = max(pss1);
yp = pii(piii) - r + r;
xp = piii - r + r;
ps = double(img(yp:yp+2*r, xp:xp+2*r));
end

function x = gau_fitting(ps, bs, r)
pm = max(max(ps));
bm = mean(mean(bs));
g0 = [bm, pm - bm, r+1, r+1, 1, 1];
residual_fun = @(g) sum(sum((gau(g, r) - ps).^2));
options = optimset('Display','off','MaxIter',1000,'MaxFunEvals',2000,'TolX',1e-10);
x = fminsearch(residual_fun, g0, options);
end

function f = gau(g, r)
[x, y] = meshgrid(1:2*r+1);
f = g(1) + g(2)*exp(-(x - g(3)).^2/(2*g(5)^2) - (y - g(4)).^2/(2*g(6)^2));
end