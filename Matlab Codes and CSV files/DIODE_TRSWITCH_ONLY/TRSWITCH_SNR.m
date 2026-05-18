clc; clear; close all;

folder = 'C:\Users\shikh\Downloads\DIODE_TRSWITCH_ONLY';
files = dir(fullfile(folder, 'TRSWITCH_*.csv'));

if isempty(files)
    error('No TRSWITCH_*.csv files found');
end

fprintf('Found %d files\n', length(files));

inputAmplitudes = [];
snrVals = [];

for i = 1:length(files)
    file = fullfile(folder, files(i).name);
    fprintf('\nProcessing: %s\n', files(i).name);
    
    try
        data = readmatrix(file);
        fprintf('  Data size: %dx%d\n', size(data,1), size(data,2));
    catch ME
        fprintf('  Error reading file: %s\n', ME.message);
        continue;
    end
    
    if size(data,2) < 2
        fprintf('  Skipping: not enough columns\n');
        continue;
    end

    t = data(:,1);
    vout = data(:,2);
    
    fprintf('  Time range: %.3f to %.3f s\n', min(t), max(t));
    fprintf('  Voltage range: %.3f to %.3f V\n', min(vout), max(vout));
    
    if length(t) < 10
        fprintf('  Skipping: too few data points (%d)\n', length(t));
        continue;
    end

    Fs = 1 / mean(diff(t));
    fprintf('  Sampling frequency: %.1f Hz\n', Fs);
    
    vout = vout - mean(vout);
    
    N = length(vout);
    window = hann(N);
    vwin = vout .* window;
    
    Y = abs(fft(vwin)/N);
    Y = Y(1:floor(N/2));
    f = Fs*(0:(N/2)-1)/N;
    
    [~, idxFund] = max(Y(6:end));
    idxFund = idxFund + 5;
    
    if idxFund <= 0 || idxFund > length(Y)
        fprintf('  Skipping: fundamental not found\n');
        continue;
    end
    
    fprintf('  Fundamental frequency: %.1f Hz\n', f(idxFund));
    
    signalBins = max(1, idxFund-3):min(length(Y), idxFund+3);
    signalPower = sum(Y(signalBins).^2);
    
    allBins = 1:length(Y);
    noiseBins = setdiff(allBins, signalBins);
    noiseBins = noiseBins(noiseBins > 5);
    noisePower = sum(Y(noiseBins).^2);
    
    fprintf('  Signal power: %.6f, Noise power: %.6f\n', signalPower, noisePower);
    
    if noisePower == 0 || signalPower == 0
        fprintf('  Skipping: zero power detected\n');
        continue;
    end
    
    snr_db = 10 * log10(signalPower / noisePower);
    
    % Fix filename parsing for TRSWITCH_XV.csv format
    filename = files(i).name;
    % Remove 'TRSWITCH_' prefix and '.csv' suffix
    voltageStr = erase(erase(filename, 'TRSWITCH_'), '.csv');
    % Remove 'V' suffix to get just the number
    voltageStr = erase(voltageStr, 'V');
    Vin = str2double(voltageStr);
    
    fprintf('  Extracted voltage: %s -> %.1f V\n', voltageStr, Vin);
    
    if isnan(Vin)
        fprintf('  Skipping: voltage is NaN\n');
        continue;
    end
    
    inputAmplitudes(end+1) = Vin;
    snrVals(end+1) = snr_db;
    
    fprintf('  SUCCESS: Vin=%.1f V, SNR=%.2f dB\n', Vin, snr_db);
end

if isempty(inputAmplitudes)
    error('No valid data found. Check the debug output above.');
end

[inputAmplitudes, idx] = sort(inputAmplitudes);
snrVals = snrVals(idx);

figure;
plot(inputAmplitudes, snrVals, '-ob', 'LineWidth', 2, 'MarkerSize', 6);
title('TX810 Output Quality - SNR vs Input Amplitude');
xlabel('Input Amplitude (V)');
ylabel('SNR (dB)');
grid on;