csv_files = dir('TRSWITCH_*.csv');
num_files = length(csv_files);

input_voltages = [];
thd_values = [];

for i = 1:num_files
    filename = csv_files(i).name;
    data = readmatrix(filename);

    % Sanity check
    if size(data, 2) < 3
        warning('Skipping file %s: not enough columns', filename);
        continue;
    end

    % Extract time and output waveform 
    time = data(:,1);
    vout = data(:,3);

    % Calculate sampling frequency
    Ts = time(2) - time(1);
    Fs = 1 / Ts;

    % Check for valid data
    if any(isnan(vout)) || length(vout) < 5
        warning('Skipping file %s: bad data', filename);
        continue;
    end

    % Calculate THD (returns result in dB)
    try
        thd_dB = thd(vout, Fs);
    catch
        warning('THD failed for %s, skipping...', filename);
        continue;
    end

    % Convert THD from dB to percentage
    thd_percentage = 100 * 10^(thd_dB/20);

    % Extract input voltage from filename 
    [~, name, ~] = fileparts(filename);
    voltageStr = erase(erase(name, 'TRSWITCH_'), 'V');
    input_v = str2double(voltageStr);

    % Save results
    input_voltages(end+1) = input_v;
    thd_values(end+1) = thd_percentage;
end

% Sort by input voltage
[input_voltages, sortIdx] = sort(input_voltages);
thd_values = thd_values(sortIdx);

% Plot distortion curve
figure;
plot(input_voltages, thd_values, '-or', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Input Amplitude (V)');
ylabel('THD (%)');
title('TX810 Switch Output Distortion (THD vs Input Voltage)');
grid on;


set(gca, 'FontSize', 12);
set(gcf, 'Position', [100, 100, 800, 600]);

% Display some statistics
fprintf('THD Analysis Results:\n');
fprintf('Number of files processed: %d\n', length(input_voltages));
fprintf('THD range: %.2f%% to %.2f%%\n', min(thd_values), max(thd_values));
fprintf('Average THD: %.2f%%\n', mean(thd_values));