function Step9_Combined_Photon_and_Polarization_Analysis
clc;
clear;

%% === User Inputs ===
fold_name = '/Users/meirakhayter/Documents/Musser Lab/GitHub/SiMRoD/'; % Update this path if needed
file_name = 'Test_SiMRoD';
g = 0.98; % Adjust g-factor for optimal overlap

%% === Part 1: Photon Distributions (g-factor Correction) ===
disp('Running Photon Distribution Analysis...');

% Load data
data_bottom = load([fold_name file_name ' bottom_intensed' '.txt']);
data_top = load([fold_name file_name ' top_intensed' '.txt']);

% Histogram settings
edges = 0:50:10000;

% Apply g-factor correction
data_bottom_corrected = data_bottom(:,10) * g;

% Calculate histograms (normalized)
h_bottom_counts = histc(data_bottom_corrected, edges);
h_bottom = h_bottom_counts(1:end-1) / sum(h_bottom_counts(1:end-1));

h_top_counts = histc(data_top(:,10), edges);
h_top = h_top_counts(1:end-1) / sum(h_top_counts(1:end-1));

% X-axis (bin centers)
edges_new = edges(2:end) - (edges(2)-edges(1))/2;

% Plot photon distributions
figure;
plot(edges_new, h_bottom, edges_new, h_top);
legend('bottom/pChannel', 'top/sChannel');
xlabel('Photon Intensity'); ylabel('Normalized Counts');
title(['Photon Distribution (g = ' num2str(g) ')']);
saveas(gcf, [fold_name 'Photon plots_g' num2str(g) '.fig']);
pause(3)

% Total photon distribution
total_photons = data_bottom_corrected + data_top(:,10);
h_total_counts = histc(total_photons, edges);
h_total_photons = h_total_counts(1:end-1) / sum(h_total_counts(1:end-1));
h_total_photons2 = [edges_new' h_total_photons];
save([fold_name 'Total Photons.txt'], 'h_total_photons2', '-ascii');

%% === Part 2: Polarization Histogram Analysis ===
disp('Running Polarization Histogram Analysis...');

% Extract intensities
spot_int_top = data_top(:,10);
spot_int_bottom = data_bottom(:,10);
s = spot_int_bottom * g;

% Calculate polarization values
p_numerator = spot_int_top - s;
p_denominator = spot_int_top + s;
p = p_numerator ./ p_denominator;

% Filter p values within bounds [-1.25, 1.25]
p_sorted = p(p > -1.25 & p < 1.25);
p_squared = p_sorted.^2;

% Save p and p^2
pol = [p_sorted, p_squared];
save([fold_name file_name ' p_cal.txt'], '-ascii', '-tabs', 'pol');

% Calculate statistics
avr_p = mean(p_sorted);
avr_p2 = mean(p_squared);
statistics = [g avr_p avr_p2];
save([fold_name file_name ' p_statistics.txt'], '-ascii', '-tabs', 'statistics');

% Polarization histogram
bin_edges = -1.25:0.05:1.25;
N = histc(p_sorted, bin_edges);
N = N(1:end-1);
N = N / sum(N);
bin_centers = (bin_edges(1:end-1) + 0.025)';

% Save histogram
xlswrite([fold_name file_name ' histogram.xls'], [bin_centers N]);

% Plot histogram
figure;
bar(bin_centers, N);
xlabel('Polarization (p)');
ylabel('Probability');
title('Polarization Histogram');

disp('Analysis Complete. All files saved.');
end
