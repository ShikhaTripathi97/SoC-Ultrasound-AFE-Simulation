% --- Settings ---
folder1 = 'C:\Users\shikh\Downloads\DIODE_TRSWITCH_ONLY';  
files1 = dir(fullfile(folder1, 'TRSWITCH_*.csv'));
folder2 = 'C:\Users\shikh\Downloads\SwitchWithGrassClipping';  
files2 = dir(fullfile(folder2, 'GCD_*.csv'));

get_rms = @(v) sqrt(mean(v.^2));

% --- No GCD ---
input_v1 = [];
rms_out1 = [];
for i = 1:length(files1)
    data = readmatrix(fullfile(folder1, files1(i).name));
    if size(data,2) < 3, continue; end
    vout = data(:,3);
    tokens = regexp(files1(i).name, '[\d.]+', 'match');
    vin = str2double(tokens{1});
    input_v1(end+1) = vin;
    rms_out1(end+1) = get_rms(vout);
end

% --- With GCD ---
input_v2 = [];
rms_out2 = [];
for i = 1:length(files2)
    data = readmatrix(fullfile(folder2, files2(i).name));
    if size(data,2) < 3, continue; end
    vout = data(:,3);
    tokens = regexp(files2(i).name, '[\d.]+', 'match');
    vin = str2double(tokens{1});
    input_v2(end+1) = vin;
    rms_out2(end+1) = get_rms(vout);
end

% --- Sort for neat plots ---
[input_v1, idx1] = sort(input_v1); rms_out1 = rms_out1(idx1);
[input_v2, idx2] = sort(input_v2); rms_out2 = rms_out2(idx2);

% --- Plot ---
figure;
semilogx(input_v1, rms_out1, '-or', 'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', 'No GCD');
hold on;
semilogx(input_v2, rms_out2, '-ob', 'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', 'With GCD');
hold off;
xlabel('Input Amplitude (V)');
ylabel('Output RMS Voltage (V)');
title('Output RMS Voltage vs Input (Logarithmic X-Axis)');
legend('Location', 'northwest');
grid on;
set(gca, 'FontSize', 13);
