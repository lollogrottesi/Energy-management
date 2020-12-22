%% Energy - distance computation for the whole dataset. Distance will be report using LAB dst and ssim.

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
nameLst = "";
%Prepare image power vector.
P_img = zeros(length(imgLst), 1);
%Prepare dst and power vectors for original DVS.
dst_ssim_ori = zeros(length(imgLst), 1);
dst_lab_ori = zeros(length(imgLst), 1);
pwr_panel_ori = zeros(length(imgLst), 1);
%Prepare dst and power vectors for modified DVS.
dst_ssim_mod = zeros(length(imgLst), 1);
dst_lab_mod = zeros(length(imgLst), 1);
pwr_panel_mod = zeros(length(imgLst), 1);
%Display variables.
vdd = 12;
vdd_original = 15;
SATURATED = 1;

for i = 1:length(imgLst)
    cd (dataFolder);
    img_RGB = imread(imgLst(i,:));
    nameLst(i) = string(imgLst(i, :));
    cd (rootFolder);
    
    %Save power of image.
    P_img(i) = ImgPwr(img_RGB);

    %Compute Cell current.
    cell_orig = Icell (img_RGB, vdd_original-1);   

    %Compute image in panel.
    img_RGB_sat = uint8(displayed_image(cell_orig, vdd_original-1, SATURATED));

    %Save panel distortion and power consumpion for original image.
    pwr_panel_ori(i) = panelPower(cell_orig, vdd_original-1);
    dst_lab_ori(i) = ImgDist(img_RGB, img_RGB_sat);
    dst_ssim_ori(i) = (1 - ssim(img_RGB, img_RGB_sat))*100;

    %Apply contrast enhancement and decrease Vdd. 
    img_RGB_mod = LCDContrastEnhancement(img_RGB, vdd/vdd_original);
    %Compute Cell current.
    cell_mod = Icell (img_RGB_mod, vdd); 

    %Compute modified image in panel.
    img_RGB_mod_sat = uint8(displayed_image(cell_mod, vdd, SATURATED));

    %Save panel distortion and power consumpion for original image.
    pwr_panel_mod(i) = panelPower(cell_mod, vdd);
    dst_lab_mod(i) = ImgDist(img_RGB, img_RGB_mod_sat);
    dst_ssim_mod(i) = (1 - ssim(img_RGB, img_RGB_mod_sat))*100;
end
cd (rootFolder);

clearvars cell_mod cell_orig dataFolder i img_RGB img_RGB_mod img_RGB_mod_sat imag_RGB_sat imgLst rootFolder SATURATED tmpLst vdd_original ans;
%% Save the out vectors in a CSV file.
csv_matrix(1,:) = nameLst';
csv_matrix(2,:) = P_img;
csv_matrix(3,:) = dst_ssim_ori;
csv_matrix(4,:) = dst_lab_ori;
csv_matrix(5,:) = pwr_panel_ori;
csv_matrix(6,:) = dst_ssim_mod;
csv_matrix(7,:) = dst_lab_mod;
csv_matrix(8,:) = pwr_panel_mod;
csv_matrix = csv_matrix';

txtID = fopen('DatasetEnergyDist.csv', 'a');
%Specify the writing format.
format = '%s;%s;%s;%s;%s;%s;%s;%s\n';
%Print the matrix according the format.
fprintf(txtID, format, csv_matrix');
fclose(txtID);
%% Read CSV and perform analisys
fileID = fopen('DatasetEnergyDist.csv', 'r');
delimiter = ';';
startRow = 1;
%Specify the writing format.
formatSpec = '%s%f%f%f%f%f%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
%Extract vectors
nameLst = dataArray{:, 1};
P_img = dataArray{:, 2};
dst_ssim_ori = dataArray{:, 3};
dst_lab_ori = dataArray{:, 4};
pwr_panel_ori = dataArray{:, 5};
dst_ssim_mod = dataArray{:, 6};
dst_lab_mod = dataArray{:, 7};
pwr_panel_mod = dataArray{:, 8};
% Clear temporary variables
clearvars delimiter formatSpec fileID dataArray startRow ans;
%% LAB vs SSIM
x = 1:length(pwr_panel_ori); 
%plot (x, P_img);
figure(1);
subplot(2, 1, 1);
plot (x, dst_lab_ori, 'Color', 'b');
hold on;
plot (x, dst_ssim_ori, 'Color', 'r');
title ('Distance of original-saturated[14V] images ');
xlabel('Figure index');
ylabel('Dst[%]');
legend('LAB', 'SSIM');
subplot(2, 1, 2);
plot (x, dst_lab_mod, 'Color', 'b');
hold on;
plot (x, dst_ssim_mod, 'Color', 'r');
title ('Distance of original-optimized[12V] images');
xlabel('Figure index');
ylabel('Dst[%]');
legend('LAB', 'SSIM');
figure(2);
plot (x, pwr_panel_ori/1000, 'Color', 'b');
hold on;
plot (x, pwr_panel_mod/1000, 'Color', 'r');
title ('Panel power consumption ');
xlabel('Figure index');
ylabel('Power[W]');
legend('Original[14V]', 'Optimized[12V]');
figure(3);
subplot(2, 1, 1);
plot(x, dst_lab_ori, 'Color', 'b');
hold on;
plot(x, dst_lab_mod, 'Color', 'r');
title ('LAB distances');
xlabel('Figure index');
ylabel('Dst[%]');
legend('LAB 14V saturation', 'LAB 12V saturation');
subplot(2, 1, 2);
plot(x, dst_ssim_ori, 'Color', 'b');
hold on;
plot(x, dst_ssim_mod, 'Color', 'r');
title ('SSIM distances');
xlabel('Figure index');
ylabel('Dst[%]');
legend('SSIM 14V saturation', 'SSIM 12V saturation');
%%
clc
clearvars