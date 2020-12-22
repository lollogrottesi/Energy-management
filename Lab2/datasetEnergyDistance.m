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
vdd_original = 15;
SATURATED = 1;

for i = 1:length(imgLst)
    cd (dataFolder);
    img_RGB = imread(imgLst(i,:));
    cd (rootFolder);
    
    if length(size(img_RGB)) == 2 %Gray images algorithm.
            img_RGB = cat(3, img_RGB, img_RGB, img_RGB);%Concatenate gray image for 3 times (R, G, B).
    end
    %Save power of image.
    P_img(i) = ImgPwr(img_RGB);

    %Compute Cell current.
    cell_orig = Icell (img_RGB, vdd_original);   

    %Compute image in panel.
    img_RGB_sat = im2uint8(displayed_image(cell_orig, vdd_original, SATURATED));

    %Save panel distortion and power consumpion for original image.
    pwr_panel_ori(i) = panelPower(cell_orig, vdd_original);
    dst_lab_ori(i) = ImgDist(img_RGB, img_RGB_sat);
    dst_ssim_ori(i) = (1 - ssim(img_RGB, img_RGB_sat))*100;

    %Apply histogram equalization. 
    img_RGB_mod = histeq(img_RGB);

    %Compute Cell current.
    cell_mod = Icell (img_RGB_mod, vdd_original); 

    %Compute modified image in panel.
    img_RGB_mod_sat = im2uint8(displayed_image(cell_mod, vdd_original, SATURATED));

    %Save panel distortion and power consumpion for original image.
    pwr_panel_mod(i) = panelPower(cell_mod, vdd_original);
    dst_lab_mod(i) = ImgDist(img_RGB_mod, img_RGB_mod_sat);
    dst_ssim_mod(i) = (1 - ssim(img_RGB_mod, img_RGB_mod_sat))*100;
end
cd (rootFolder);

%%
nameLst = "";
for i=1:length(imgLst)
    nameLst(i) = string(imgLst(i, :));
end

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
%%
clc
clearvars