% CSV Columns:
% Col1: Time
% Col2: VIN  = V(C10:2)
% Col3: VOH  = V(R10:2)
% Col4: VOL  = V(U2:VOL)

clear; clc;

%% Load CSV
T = readtable('AD8331gainfin.csv','VariableNamingRule','preserve');  

time = T{:,1};
vin  = T{:,2};
voh  = T{:,3};
vol  = T{:,4};

%% Remove NaN rows (in case sweep inserted them)
mask = ~isnan(time) & ~isnan(vin) & ~isnan(voh) & ~isnan(vol);
time = time(mask);
vin  = vin(mask);
voh  = voh(mask);
vol  = vol(mask);

%% Sweep configuration (adjust if your PSpice sweep changed)
VGAIN_values = 0:0.1:1.0;  % Matches your sweep setup in PSpice
nSweeps = numel(VGAIN_values);

% Detect points per sweep by finding where time resets to 0
reset_idx = find(time < time(1) + eps); 
if numel(reset_idx) > 1
    pts_per_sweep = reset_idx(2) - reset_idx(1);
else
    pts_per_sweep = numel(time) / nSweeps; % fallback if no resets found
end
pts_per_sweep = floor(pts_per_sweep);

%% Preallocate gain arrays
gains_vv = zeros(size(VGAIN_values));
gains_db = zeros(size(VGAIN_values));

%% Loop through sweeps
for k = 1:nSweeps
    idx = (k-1)*pts_per_sweep + (1:pts_per_sweep);

    vin_seg  = vin(idx);
    voh_seg  = voh(idx);
    vol_seg  = vol(idx);

    % Differential output
    vdiff_seg = vol_seg - voh_seg;

    % Skip first 10% of samples to avoid startup transient
    skip = floor(0.1 * pts_per_sweep);
    vin_seg  = vin_seg(skip+1:end);
    vdiff_seg = vdiff_seg(skip+1:end);

    % Peak-to-peak
    vin_pp  = max(vin_seg) - min(vin_seg);
    vout_pp = max(vdiff_seg) - min(vdiff_seg);

    % Gain
    gains_vv(k) = vout_pp / vin_pp;
    gains_db(k) = 20*log10(gains_vv(k));
end

%% === Plot 1: Gain vs VGAIN ===
figure;
plot(VGAIN_values, gains_db, '-o', 'LineWidth', 1.5);
xlabel('VGAIN Control Voltage (V)');
ylabel('Gain (dB)');
title('AD8331 Gain vs VGAIN');
grid on;

%% Display numeric table
disp(table(VGAIN_values', gains_vv', gains_db', ...
    'VariableNames', {'VGAIN_V','Gain_VV','Gain_dB'}));

%% === Plot 2: Example waveforms at min/mid/max gain ===
example_steps = [1, ceil(nSweeps/2), nSweeps]; % min, mid, max gain

figure;
for p = 1:numel(example_steps)
    k = example_steps(p);
    idx = (k-1)*pts_per_sweep + (1:pts_per_sweep);
    vdiff_seg = vol(idx) - voh(idx);

    subplot(numel(example_steps),1,p);
    plot(time(idx), vin(idx), 'g', 'LineWidth', 1.2); hold on;
    plot(time(idx), vdiff_seg, 'r', 'LineWidth', 1.2);
    legend('Input (VIN)', 'Diff Output (VOL - VOH)', 'Location', 'best');
    xlabel('Time (s)');
    ylabel('Voltage (V)');
    title(sprintf('Waveform at VGAIN = %.1f V  |  Gain = %.2f dB', ...
        VGAIN_values(k), gains_db(k)));
    grid on;
end
