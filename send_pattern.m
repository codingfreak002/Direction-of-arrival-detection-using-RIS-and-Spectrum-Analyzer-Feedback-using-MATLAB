% Function to convert and send a single pattern
function send_pattern(serialObj,pattern)
    if length(pattern) ~= 160
        error('Pattern must be exactly 160 bits long.');
    end
 
    % Convert the pattern to a string of '0' and '1' characters
    pattern_str = num2str(pattern(:)'); % Convert the array to a row vector and then to string
    pattern_str = strrep(pattern_str, ' ', ''); % Remove any spaces

    % Send the pattern
    fwrite(serialObj, pattern_str, 'char');
end