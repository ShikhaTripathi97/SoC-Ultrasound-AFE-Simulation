
% Folder 1: Without GCD
folder1 = 'C:\Users\shikh\Downloads\DIODE_TRSWITCH_ONLY';  
files1 = dir(fullfile(folder1, 'TRSWITCH_*.csv'));

% Folder 2: With GCD
folder2 = 'C:\Users\shikh\Downloads\SwitchWithGrassClipping';  
files2 = dir(fullfile(folder2, 'GCD_*.csv'));

voltage1 = []; snr1 = [];
voltage2 = []; snr2 = [];

fprintf("Processing Folder 1 (No GCD):\n");
for i = 1:length(files1)
    file = fullfile(folder1, files1(i).name);
    data = readmatrix(file);
    
    if size(data, 2) < 3
        fprintf('Skipping %s: not enough columns.\n', files1(i).name);
        continue;
    end
    
    t = data(:,1);
    vout = data(:,3) - mean(data(:,3));
    Fs = 1 / mean(diff(t));
    N = length(vout);

    % Apply Hanning window
    win = hann(N);
    vwin = vout .* win;
    Y = abs(fft(vwin) / N);
    Y = Y(1:floor(N/2));
    
    % Find fundamental
    [~, idxFund] = max(Y(6:end));
    idxFund = idxFund + 5;

    sig_bins = max(1, idxFund-2) : min(length(Y), idxFund+2);
    noise_bins = setdiff(1:length(Y), sig_bins);
    
    signal_energy = sum(Y(sig_bins).^2);
    noise_energy = sum(Y(noise_bins).^2);

    if noise_energy == 0 || signal_energy == 0
        snr_dB = NaN;
        fprintf('✖ Skipped %s: zero signal/noise energy.\n', files1(i).name);
    else
        snr_dB = 10 * log10(signal_energy / noise_energy);
        parts = split(files1(i).name, {'_', 'V', '.'});
        vin = str2double(parts{2});
        fprintf('✔ %s — %.2fV, SNR = %.2f dB\n', files1(i).name, vin, snr_dB);

        voltage1(end+1) = vin;
        snr1(end+1) = snr_dB;
    end
end

fprintf("\nProcessing Folder 2 (With GCD):\n");
for i = 1:length(files2)
    file = fullfile(folder2, files2(i).name);
    data = readmatrix(file);
    
    if size(data, 2) < 3
        fprintf('Skipping %s: not enough columns.\n', files2(i).name);
        continue;
    end
    
    t = data(:,1);
    vout = data(:,3) - mean(data(:,3));
    Fs = 1 / mean(diff(t));
    N = length(vout);

    % Apply Hanning window
    win = hann(N);
    vwin = vout .* win;
    Y = abs(fft(vwin) / N);
    Y = Y(1:floor(N/2));
    
    [~, idxFund] = max(Y(6:end));
    idxFund = idxFund + 5;

    sig_bins = max(1, idxFund-2) : min(length(Y), idxFund+2);
    noise_bins = setdiff(1:length(Y), sig_bins);

    signal_energy = sum(Y(sig_bins).^2);
    noise_energy = sum(Y(noise_bins).^2);

    if noise_energy == 0 || signal_energy == 0
        snr_dB = NaN;
        fprintf('✖ Skipped %s: zero signal/noise energy.\n', files2(i).name);
    else
        snr_dB = 10 * log10(signal_energy / noise_energy);
        parts = split(files2(i).name, {'_', 'V', '.'});
        vin = str2double(parts{2});
        fprintf('✔ %s — %.2fV, SNR = %.2f dB\n', files2(i).name, vin, snr_dB);

        voltage2(end+1) = vin;
        snr2(end+1) = snr_dB;
    end
end

% Sort and clean
[voltage1, idx1] = sort(voltage1); snr1 = snr1(idx1);
[voltage2, idx2] = sort(voltage2); snr2 = snr2(idx2);

% Plot
% Plot (Logarithmic X-axis)
figure;
hold on;
% === Plot ===
figure;
semilogx(voltage1, snr1, '-or', 'LineWidth', 2, 'DisplayName', 'Without GCD');
hold on;
semilogx(voltage2, snr2, '-ob', 'LineWidth', 2, 'DisplayName', 'With GCD');
xlabel('Input Voltage (V)');
xlabel('Input Amplitude (V)');
ylabel('SNR (dB)');
title('SNR Comparison (Log X): TX810 With vs Without Grass Clipping Diode');
legend('Location', 'best');
grid on;