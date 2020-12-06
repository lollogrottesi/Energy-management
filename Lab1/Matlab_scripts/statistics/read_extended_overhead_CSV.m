function [time_overhead, energy_overhead, timeout_idle, timeout_sleep] = read_extended_overhead_CSV(filename)
    delimiter = ';';

    % Format for each line of text:
    %   column1: categorical (%C)
    %	column2: double (%f)
    %   column3: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%C%f%f%f%f%[^\n\r]';

    % Open the text file.
    fileID = fopen(filename,'r');

    % Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);

    % Close the text file.
    fclose(fileID);

    % Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    % Allocate imported array to column variable names
    timeout_idle = dataArray{:, 2};
    timeout_sleep = dataArray{:, 3};
    time_overhead = dataArray{:, 4};
    energy_overhead = dataArray{:, 5};

    % Clear temporary variables
    clearvars filename delimiter formatSpec fileID dataArray ans;
end