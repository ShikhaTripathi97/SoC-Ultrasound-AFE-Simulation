% TX810 Switch Output Comparison

csv_files = dir('TRSWITCH_*.csv');
num_files = length(csv_files);

if num_files == 0
    error('No waveform CSV files found.');
end

colors = lines(num_files); 
figure('Name', 'TX810 Output Comparison', 'NumberTitle', 'off');
hold on;

for i = 1:num_files
    filename = csv_files(i).name;
    data = readmatrix(filename);

    % Extract time and output only
    time = data(:,1);
    output = data(:,3);

    % Voltage level from filename
    [~, name, ~] = fileparts(filename);
    voltageStr = erase(name, 'TRSWITCH_');

    % Plot only output
    plot(time, output, 'LineWidth', 1.5, 'DisplayName', [voltageStr ' Input'], ...
         'Color', colors(i,:));
end

xlabel('Time (s)');
ylabel('Output Voltage (V)');
title('TX810 Switch Output vs Time for Varying Input Amplitudes');
legend('Location', 'best');
grid on;
