BUFFER_SIZE = 2^19;
pAddress = 'USB0::0x0B5B::0xFFF9::1329046_1768_55::INSTR';
centerFreq = 1e9; 
span = 1e9; 
rbw = 10e3; 
vbw = 10e3; 
startFreq = 5E9;
stopFreq = 6.0E9;
numpoints = 41;
bw = 300E3;
frequenciesToMeasure = [900e6, 1e9, 1.1e9]; 

instr = visa('ni', pAddress);
set(instr, 'InputBufferSize', BUFFER_SIZE);
set(instr, 'Timeout', 30); 
fopen(instr);
disp('Spectrum analyzer connected');

fprintf(instr, ['SENS:FREQ:START ' num2str(startFreq)]);
fprintf(instr, ['SENS:FREQ:STOP ' num2str(stopFreq)]);
fprintf(instr, ['SENS:SWE:POIN ' num2str(numpoints)]);
fprintf(instr, ['SENS:BAND:RES ' num2str(bw)]);
fprintf(instr, sprintf('FREQ:CENT %e', centerFreq));
fprintf(instr, sprintf('FREQ:SPAN %e', span));
fprintf(instr, sprintf('BAND:RES %e', rbw));
fprintf(instr, sprintf('BAND:VID %e', vbw));

fprintf(instr, 'INIT:IMM; *WAI');

powerLevels = zeros(size(frequenciesToMeasure));
for i = 1:length(frequenciesToMeasure)
    freq = frequenciesToMeasure(i);
    fprintf(instr, sprintf('CALC:MARK1:X %e', freq)); 
    fprintf(instr, 'CALC:MARK1:Y?'); 
    powerLevels(i) = str2double(fscanf(instr)); 
end

disp('Power levels at specific frequencies:');
for i = 1:length(frequenciesToMeasure)
    fprintf('Frequency: %.2f MHz, Power: %.2f dBm\n', frequenciesToMeasure(i)/1e6, powerLevels(i));
end

% Close VISA session
fclose(instr);
delete(instr);
clear instr;
