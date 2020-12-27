%% Algorithm for display OLED power optimiziation.
clc
clear

dstThreshold = 10; % 1%, 5%, 10%.
rootFolder = pwd;

dataFolder = rootFolder + "\dataset";
cd (dataFolder);
tmpLst = ls;

imgLst = tmpLst;
imgLst(1, :) = []; %cut '. '
imgLst(1, :) = []; %cut '.. '
i=1;

while i < length(imgLst)
    if contains(imgLst(i,:), 'Thumbs.db')
        imgLst(i,:) = [];          %Drop string.
    end 
    i=i+1;
end

cd (rootFolder);
energy_saving = zeros(length(imgLst), 1);
dst_img = zeros(length(imgLst), 1);
nameLst = "";

for i = 1:length(imgLst)
    cd (dataFolder);
    img_RGB = imread(imgLst(i,:));
    nameLst(i) = string(imgLst(i, :));
    cd (rootFolder);

    %Start DVS algorithm.
    vdd_original = 15;
    vdd_step = 0.2;
    SATURATED = 1;
    %Compute original image power consumption.Result is mW.
    cell_orig = Icell (img_RGB, vdd_original);   
    pwr_org = panelPower(cell_orig, vdd_original);
    %Update the img_RGB variable with saturated one. The optimization will
    %be curried with respect this variable.
    img_RGB = uint8(displayed_image(cell_orig, vdd_original, SATURATED));
    
    %Initialize cost variables.
    img_DVS_sat = img_RGB;
    DVS_pwr = pwr_org;
    
    %Decrease vdd_taget.
    vdd_target = vdd_original - vdd_step;
    
    %Check the optimal transformation. 
    %Apply all 3 transformations: BrightnessCompensation,
    %ContrastEnhancement and both. optimalTransformation function will
    %return  the best trasformation considering the power - distance plain.
    [tmp_img_DVS_sat, tmp_DVS_pwr, dst] = optimalTransformation(img_RGB, vdd_target, vdd_original, SATURATED);
    
    %Check if the transormation respect the distance threshold, try to
    %reach a local minima iterating the optimalTransformation.
    while tmp_DVS_pwr < DVS_pwr && dst <= dstThreshold
        vdd_target = vdd_target - vdd_step;
        img_DVS_sat = tmp_img_DVS_sat;  %img_DVS_sat is an output of the loop. Rapresent the optimized image.
        DVS_pwr = tmp_DVS_pwr;          %DVS_pwr is an output of the loop. Rapresent the enrgy of the optimized image.
        %Check the optimal transformation.
        [tmp_img_DVS_sat, tmp_DVS_pwr, dst] = optimalTransformation(img_RGB, vdd_target, vdd_original, SATURATED);
    end
    
    %Power / Distance exctraction.
    dst_img(i) = (1 - ssim(img_RGB, img_DVS_sat))*100;
    energy_saving(i) = ((pwr_org - DVS_pwr)/pwr_org)*100;
 
end

cd (rootFolder);

clearvars imgLst cell_orig dataFolder dst dstThreshold DVS_pwr i img_DVS_sat img_RGB pwr_org rootFolder SATURATED tmp_DVS_pwr tmp_img_DVS_sat tmpLst vdd_original vdd_step vdd_target ans;
%Results:
%Average for dstMax 1%  is  11.8451% saving, max distance 0.998.
%Average for dstMax 5%  is  26.6767% saving, max distance 4.9988.
%Average for dstMax 10% is  36.5679% saving, max distance 9.9946.
%% Save the out vectors in a CSV file.
csv_matrix(1,:) = nameLst';
csv_matrix(2,:) = energy_saving;
csv_matrix(3,:) = dst_img;
csv_matrix = csv_matrix';

txtID = fopen('EnergySavingOLED10perc.csv', 'a');
%Specify the writing format.
format = '%s;%s;%s\n';
%Print the matrix according the format.
fprintf(txtID, format, csv_matrix');
fclose(txtID);

clearvars delimiter format csv_matrix txtID dataArray startRow ans;
%% Read CSV and perform analisys
fileID = fopen('EnergySavingOLED10perc.csv', 'r');
delimiter = ';';
startRow = 1;
%Specify the writing format.
formatSpec = '%s%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
%Extract vectors
nameLst = dataArray{:, 1};
energy_saving = dataArray{:, 2};
dst_img = dataArray{:, 3};
% Clear temporary variables
clearvars delimiter formatSpec fileID dataArray startRow ans;
%% Plot energy saving
x = 1:length(energy_saving);
plot(x, energy_saving);
xlabel('Figure index');
ylabel('Energy saving');
title('Image energy saving 1% distance');
clearvars x
%% Reset environment.
clc
clear