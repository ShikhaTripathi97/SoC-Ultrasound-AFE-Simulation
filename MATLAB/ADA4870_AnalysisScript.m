clc; clear;

% === Folder with CSV files ===
folder = 'C:\Users\shikh\Downloads\ADA4870'; 
files = dir(fullfile(folder, '*.csv'));

% === Initialize Arrays ===
input_amplitudes = [];
output_amplitudes = [];
gain_values = [];
all_data = {};

% === Clipping Threshold ===
clipping_threshold = 36; 

% === Load and process data ===
for i = 1:length(files)
    filename = fullfile(folder, files(i).name);
    data = readmatrix(filename);

    t = data(:,1);
    vin = data(:,3);  % Column 3: Input
    vout = data(:,2); % Column 2: Output

    vin = vin - mean(vin);
    vout = vout - mean(vout);

    vin_pp = max(vin) - min(vin);
    vout_pp = max(vout) - min(vout);
    gain = vout_pp / vin_pp;

    input_amplitudes(end+1) = vin_pp / 2;
    output_amplitudes(end+1) = vout_pp;
    gain_values(end+1) = gain;

    % Save waveforms and labels for plotting later
    all_data{end+1} = struct('t', t, 'vin', vin, 'vout', vout, 'clip', max(abs(vout)) >= clipping_threshold);
end

% === Sort data by input amplitude ===
[input_amplitudes, sortIdx] = sort(input_amplitudes);
output_amplitudes = output_amplitudes(sortIdx);
gain_values = gain_values(sortIdx);
all_data = all_data(sortIdx);

% === Plot 1: Input vs Output Overlay ===
figure(1); clf; hold on;
title('Overlay of Input and Output Waveforms');
xlabel('Time (s)'); ylabel('Voltage (V)');
for i = 1:length(all_data)
    d = all_data{i};
    plot(d.t, d.vin, 'k'); % Input: black
    if d.clip
        plot(d.t, d.vout, 'r'); % Clipping output
    else
        plot(d.t, d.vout, 'b');   % Normal output
    end
end
legend('Input', 'Output (No Clipping)', 'Output (Clipping)');
grid on;

% === Plot 2: Output swing vs Input amplitude ===
figure(2); clf;
semilogx(input_amplitudes, output_amplitudes, '-o', 'LineWidth', 2);
xlabel('Input Amplitude (V)');
ylabel('Output Peak-to-Peak Voltage (V)');
title('Output Swing vs Input Amplitude');
grid on;

% === Plot 3: Gain Linearity ===
figure(3); clf;
semilogx(input_amplitudes, gain_values, '-s', 'LineWidth', 2);
xlabel('Input Amplitude (V)');
ylabel('Gain (V/V)');
title('Linearity of Gain vs Input Amplitude');
grid on;
