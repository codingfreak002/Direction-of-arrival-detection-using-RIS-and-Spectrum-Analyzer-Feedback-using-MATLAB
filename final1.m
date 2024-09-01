clc;
clear;
close all;

%%%%%%%%%%%%% Establishing serial connection with aurdino

serialObj = serial('COM3', 'BaudRate', 9600); % Replace 'COM3' with your Arduino's serial port
fopen(serialObj); % Open the serial port
pause(2); % Wait for the connection to initialize

%%%%%%%%%%% Spectrum analyzer parameters
BUFFER_SIZE = 2^19;
pAddress = 'USB0::0x0B5B::0xFFF9::1329046_1768_55::INSTR';
centerFreq = 5.5e9; 
span = 0.01e9; 
rbw = 10e3; 
vbw = 30e3; 
startFreq = 5.495e9;
stopFreq = 5.505e9;
bw = 300e3;
targetFreq = 5.5e9;  

instr = visa('ni', pAddress);
set(instr, 'InputBufferSize', BUFFER_SIZE);
set(instr, 'Timeout', 30); 
fopen(instr);
disp('Spectrum analyzer connected');

fprintf(instr, ['SENS:FREQ:START ' num2str(startFreq)]);
fprintf(instr, ['SENS:FREQ:STOP ' num2str(stopFreq)]);
fprintf(instr, ['SENS:BAND:RES ' num2str(bw)]);
fprintf(instr, sprintf('FREQ:CENT %e', centerFreq));
fprintf(instr, sprintf('FREQ:SPAN %e', span));
fprintf(instr, sprintf('BAND:RES %e', rbw));
fprintf(instr, sprintf('BAND:VID %e', vbw));

%%%%%%%%%%%%%%%%%%%%%%%%%%% Assign constant data

L = 80; % number of random patterns
M=16; % Number of elements in each row
N=10; % Number of elements in each row

theta = -90:90; % Create the original array of angles from -90 to 90
filtered_array = theta(theta < -15 | theta > 15); % Filter out angles from -15 to 15
RandAngle = datasample(filtered_array, L, 'Replace', false); % Randomly pick L values from the filtered array

allPowerLevels = zeros(L,1);
B_matrices = cell(L,1);
for i = 1:L
    [actual_pattern, map_pattern] = pattern_gen(M,N, RandAngle(i)); % Array Pattern generated for the randomly selected angle
    B_matrices{i} = actual_pattern; % Store the result in the cell array
    send_pattern(serialObj, map_pattern);
    pause(4.5);
    fprintf(instr, sprintf('CALC:MARK1:X %e', targetFreq));
    fprintf(instr, 'CALC:MARK1:Y?');
    allPowerLevels(i) = str2double(fscanf(instr));
end

disp('Random Pattern Sent');
B_matrix = cell2mat(B_matrices);
H_matrix = Phi_mat_gen(M,N,L,B_matrices,theta);
phi_mat = abs(H_matrix);

temp2 = allPowerLevels / 10;
y = 10 .^ temp2; % The received signal without noise
y = abs(y);

for j = 1:10
    x_est = OMP_algo(phi_mat,y);
    y = abs(phi_mat * x_est);
end

% Plots to compare the actual signal and the estimated signal x_est
figure;
plot(theta, x_est);
xlabel('Angle (degrees)');
ylabel('Magnitude of Estimated X');
title('Estimated X vs Angle');

fclose(serialObj);
delete(serialObj);
clear serialObj;