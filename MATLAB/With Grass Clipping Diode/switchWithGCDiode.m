csv_files = dir('GCD_*.csv');
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
    voltageStr = erase(name, 'GCD_');

    % Plot using logarithmic X-axis
    semilogx(time, output, 'LineWidth', 1.5, 'DisplayName', [voltageStr ' Input'], ...
             'Color', colors(i,:));
end

xlabel('Time (s)');
ylabel('Output Voltage (V)');
title('TR Switch with Grass Clipping Diodes Output (Log X-Axis)');
legend('Location', 'best');
grid on;
