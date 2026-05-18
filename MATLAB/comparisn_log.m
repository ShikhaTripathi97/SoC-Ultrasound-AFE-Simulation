% === Folder 1: Without GCD ===
folder1 = 'C:\Users\shikh\Downloads\DIODE_TRSWITCH_ONLY'; 
files1 = dir(fullfile(folder1, 'TRSWITCH_*.csv'));

input_voltages_1 = [];
thd_values_1 = [];

for i = 1:length(files1)
    filename = fullfile(folder1, files1(i).name);
    data = readmatrix(filename);
    if size(data,2) < 3, continue; end
    time = data(:,1);
    vout = data(:,3);
    if any(isnan(vout)) || length(vout) < 5, continue; end
    Fs = 1 / (time(2) - time(1));
    try
        thd_val = thd(vout, Fs);
    catch
        continue;
    end
    % Extract voltage from filename
    tokens = regexp(files1(i).name, '[\d.]+', 'match');
    input_v = str2double(tokens{1});
    input_voltages_1(end+1) = input_v;
    thd_values_1(end+1) = thd_val;
end

% === Folder 2: With GCD ===
folder2 = 'C:\Users\shikh\Downloads\SwitchWithGrassClipping';  
files2 = dir(fullfile(folder2, 'GCD_*.csv'));

input_voltages_2 = [];
thd_values_2 = [];

for i = 1:length(files2)
    filename = fullfile(folder2, files2(i).name);
    data = readmatrix(filename);
    if size(data,2) < 3, continue; end
    time = data(:,1);
    vout = data(:,3);
    if any(isnan(vout)) || length(vout) < 5, continue; end
    Fs = 1 / (time(2) - time(1));
    try
        thd_val = thd(vout, Fs);
    catch
        continue;
    end
    tokens = regexp(files2(i).name, '[\d.]+', 'match');
    input_v = str2double(tokens{1});
    input_voltages_2(end+1) = input_v;
    thd_values_2(end+1) = thd_val;
end

% === Sort and Plot (Log X) ===
[input_voltages_1, idx1] = sort(input_voltages_1);
thd_values_1 = thd_values_1(idx1);

[input_voltages_2, idx2] = sort(input_voltages_2);
thd_values_2 = thd_values_2(idx2);

figure;
semilogx(input_voltages_1, thd_values_1, '-or', 'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', 'Without GCD');
hold on;
semilogx(input_voltages_2, thd_values_2, '-ob', 'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', 'With GCD');
hold off;
xlabel('Input Amplitude (V)');
ylabel('THD (dB)');
title('THD vs Input Voltage (Logarithmic X-Axis)');
legend('Location', 'best');
grid on;
set(gca, 'FontSize', 13);

