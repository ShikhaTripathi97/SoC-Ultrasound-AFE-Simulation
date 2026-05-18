clc; clear; close all;

% === Folder paths ===
folder_with = 'C:\Users\shikh\Downloads\SwitchWithGrassClipping';  % With GCD
folder_without = 'C:\Users\shikh\Downloads\DIODE_TRSWITCH_ONLY';   % Without GCD

% === Load CSV files ===
files_with = dir(fullfile(folder_with, 'GCD_*.csv'));
files_without = dir(fullfile(folder_without, 'TRSWITCH_*.csv'));

% === Init storage ===
input_voltages = [];
thd_with = [];
thd_without = [];

% === THD Calculation Function ===
compute_thd = @(vout, Fs) ...
    100 * sqrt(sum(abs(fft(vout)).^2) - max(abs(fft(vout)).^2)) / max(abs(fft(vout)).^2);

% === Loop through files ===
for i = 1:length(files_with)
    try
        % Parse input voltage from filename
        vin_str = regexp(files_with(i).name, '\d+', 'match');
        Vin = str2double(vin_str{1});
        
        % Read WITH GCD
        data_with = readmatrix(fullfile(folder_with, files_with(i).name));
        t_with = data_with(:,1); y_with = data_with(:,end);
        Fs_with = 1 / mean(diff(t_with));
        thd_val_with = compute_thd(y_with, Fs_with);

        % Read WITHOUT GCD
        file_match = sprintf('TRSWITCH_%dV.csv', Vin);
        if ~exist(fullfile(folder_without, file_match), 'file'), continue; end
        data_without = readmatrix(fullfile(folder_without, file_match));
        t_wo = data_without(:,1); y_wo = data_without(:,end);
        Fs_wo = 1 / mean(diff(t_wo));
        thd_val_without = compute_thd(y_wo, Fs_wo);

        % Save results
        input_voltages(end+1) = Vin;
        thd_with(end+1) = thd_val_with;
        thd_without(end+1) = thd_val_without;
    catch
        warning('Skipping entry %s due to error.', files_with(i).name);
    end
end

% === Sort for plotting ===
[input_voltages, idx] = sort(input_voltages);
thd_with = thd_with(idx);
thd_without = thd_without(idx);

% === Plot ===
figure;
semilogx(input_voltages, thd_without, '-or', 'LineWidth', 2, 'DisplayName', 'Without GCD');
hold on;
semilogx(input_voltages, thd_with, '-ob', 'LineWidth', 2, 'DisplayName', 'With GCD');
xlabel('Input Voltage (V)');
ylabel('THD (%)');
title('THD vs Input Voltage (Frequency Domain)');
legend('Location', 'northeast');
grid on;
set(gca, 'FontSize', 12);
