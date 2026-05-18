csv_files = dir('TRSWITCH_*.csv');

input_voltages = [];
thd_values = [];

for i = 1:length(csv_files)
    filename = csv_files(i).name;
    data = readmatrix(filename);

    if size(data,2) < 2
        continue;
    end

    input_v = str2double(erase(erase(filename, 'TRSWITCH_'), 'V'));
    time = data(:,1);
    vout = data(:,end);

    Fs = 1 / (time(2) - time(1));  % Sampling frequency
    thd_val = thd(vout, Fs);       

    input_voltages(end+1) = input_v;
    thd_values(end+1) = thd_val;
end

% Sort 
[input_voltages, idx] = sort(input_voltages);
thd_values = thd_values(idx);

% Plot distortion curve
figure;
plot(input_voltages, thd_values, '-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Input Amplitude (V)');
ylabel('THD (%)');
title('TX810 Switch Distortion - THD vs Input Voltage');
grid on;


csv_files = dir('TRSWITCH_*.csv');
num_files = length(csv_files);


input_voltages = [];
thd_values = [];

for i = 1:num_files
    filename = csv_files(i).name;
    data = readmatrix(filename);

    % Sanity check: must have at least time + 2 columns
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

    
    if any(isnan(vout)) || length(vout) < 5
        warning('Skipping file %s: bad data', filename);
        continue;
    end

    
    try
        thd_val = thd(vout, Fs);
    catch
        warning('THD failed for %s, skipping...', filename);
        continue;
    end

    % Extract input voltage from filename 
    [~, name, ~] = fileparts(filename);
    voltageStr = erase(erase(name, 'TRSWITCH_'), 'V');
    input_v = str2double(voltageStr);

    % Save results
    input_voltages(end+1) = input_v;
    thd_values(end+1) = thd_val;
end


[input_voltages, sortIdx] = sort(input_voltages);
thd_values = thd_values(sortIdx);


figure;
plot(input_voltages, thd_values, '-or', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Input Amplitude (V)');
ylabel('THD (%)');
title('TX810 Switch Output Distortion (THD vs Input Voltage)');
grid on;
