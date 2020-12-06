%% 
% Analysis of idle times with respect power saving, filename holds the dataset name.


% Initialize variables.
filename = 'custom_workload_2_dpm_report_idle.csv';
delimiter = ';';

% Format for each line of text:
%   column1: categorical (%C)
%	column2: double (%f)
%   column3: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%C%f%f%[^\n\r]';

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
DistName = dataArray{:, 1};
TimeoutIdle = dataArray{:, 2};
energySaved = dataArray{:, 3};


% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;

plot (TimeoutIdle, energySaved);
xlabel('Timeout idle [us]');
ylabel('Energy saves [%]');
grid on;


%% Initialize variables.
% Analysis of idle times and sleep times with respect power saving, filename holds the dataset name.

filename = 'custom_workload_2_dpm_report_idle_sleep.csv';
delimiter = ';';

% Format for each line of text:
%   column1: categorical (%C)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%C%f%f%f%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);

% Close the text file.
fclose(fileID);

% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

% Allocate imported array to column variable names
DistributionName = dataArray{:, 1};
TimoutIdle = dataArray{:, 2};
TimeoutSleep = dataArray{:, 3};
energySaved = dataArray{:, 4};

% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;

scatter3(TimoutIdle, TimeoutSleep, energySaved);
xlabel('Timeout idle [us]');
ylabel('Timeout sleep [us]');
zlabel('Energy saved [%]');
grid on;
%% Overhead Analisys
% Initialize variables.
filename = 'uniform_1_400_dpm_report_overhead_idle.csv';
[timeOverhead_400 ,energyOverhead_400, TimeoutIdle] = read_overhead_CSV(filename);

filename = 'uniform_1_100_dpm_report_overhead_idle.csv';
[timeOverhead_100 ,energyOverhead_100] = read_overhead_CSV(filename);

filename = 'gaussian_dpm_report_overhead_idle.csv';
[timeOverhead_gaussian ,energyOverhead_gaussian] = read_overhead_CSV(filename);

filename = 'trimodal_dpm_report_overhead_idle.csv';
[timeOverhead_trimodal ,energyOverhead_trimodal] = read_overhead_CSV(filename);

filename = 'exp_dpm_report_overhead_idle.csv';
[timeOverhead_exp ,energyOverhead_exp] = read_overhead_CSV(filename);

plot (TimeoutIdle, energyOverhead_400, 'r');
hold on
plot (TimeoutIdle, energyOverhead_100, 'b');
hold on
plot (TimeoutIdle, energyOverhead_gaussian, 'g');
hold on
plot (TimeoutIdle, energyOverhead_trimodal, 'm');
hold on
plot (TimeoutIdle, energyOverhead_exp, 'c');

xlabel('Timeout idle [us]');
ylabel('Energy overhead [J]');
grid on;

legend ('Uniform 1-400', 'Uniform 1-400', 'Gaussian', 'Trimodal', 'Exponential');
%% Overhead Analisys extended
% Initialize variables.
filename = 'uniform_1_400_dpm_report_overhead_idle_sleep.csv';
[timeOverhead_400 ,energyOverhead_400, TimeoutIdle, TimeoutSleep] = read_extended_overhead_CSV(filename);

filename = 'uniform_1_100_dpm_report_overhead_idle_sleep.csv';
[timeOverhead_100 ,energyOverhead_100] = read_extended_overhead_CSV(filename);

filename = 'gaussian_dpm_report_overhead_idle_sleep.csv';
[timeOverhead_gaussian ,energyOverhead_gaussian] = read_extended_overhead_CSV(filename);

filename = 'trimodal_dpm_report_overhead_idle_sleep.csv';
[timeOverhead_trimodal ,energyOverhead_trimodal] = read_extended_overhead_CSV(filename);

filename = 'exp_dpm_report_overhead_idle_sleep.csv';
[timeOverhead_exp ,energyOverhead_exp] = read_extended_overhead_CSV(filename);


scatter3(TimeoutIdle, TimeoutSleep, energyOverhead_gaussian, 'r');
%hold on
%scatter3(TimeoutIdle, TimeoutSleep, timeOverhead_100, 'b');
%hold on

xlabel('Timeout idle [us]');
ylabel('Timeout sleep [us]');
zlabel('Energy overhead [J]');
grid on;
%%