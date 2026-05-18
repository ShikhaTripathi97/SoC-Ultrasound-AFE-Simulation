clc; clear; close all;

% Define test voltages
test_voltages = [1, 2, 3, 4, 5, 10, 20];

% Define folder paths
folder_with_diodes = 'C:\Users\shikh\Downloads\SwitchWithGrassClipping';
folder_without_diodes = 'C:\Users\shikh\Downloads\DIODE_TRSWITCH_ONLY';

% Arrays to store Vpp values
vpp_with_diodes = [];
vpp_without_diodes = [];

for i = 1:length(test_voltages)
    Vin = test_voltages(i);

    % File names
    file_with = fullfile(folder_with_diodes, sprintf('GCD_%dV.csv', Vin));
    file_without = fullfile(folder_without_diodes, sprintf('TRSWITCH_%dV.csv', Vin));

    % Compute Vpp for WITH diodes
    if exist(file_with, 'file')
        data = readmatrix(file_with);
        if size(data, 2) >= 2
            vout = data(:,2); % Use correct column
            vpp_with_diodes(end+1) = max(vout) - min(vout);
        else
            vpp_with_diodes(end+1) = NaN;
        end
    else
        vpp_with_diodes(end+1) = NaN;
    end

    % Load and compute Vpp for WITHOUT diodes
    if exist(file_without, 'file')
        data = readmatrix(file_without);
        if size(data, 2) >= 2
            vout = data(:,2);
            vpp_without_diodes(end+1) = max(vout) - min(vout);
        else
            vpp_without_diodes(end+1) = NaN;
        end
    else
        vpp_without_diodes(end+1) = NaN;
    end
end

% Plot Vpp Comparison with log X-axis
figure;
semilogx(test_voltages, vpp_with_diodes, '-ob', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogx(test_voltages, vpp_without_diodes, '-or', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Input Voltage (V)');
ylabel('Output Vpp (V)');
title('Peak-to-Peak Voltage Comparison (Log Scale)');
legend('With Grass Diodes', 'Without Grass Diodes', 'Location', 'best');
grid on;
set(gca, 'FontSize', 12);
