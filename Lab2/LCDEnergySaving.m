%%Algorithm part 2 Brightness compensation.
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
%i=11;
for i = 1:length(imgLst)
    cd (dataFolder);
    img_RGB = imread(imgLst(i,:));
    cd (rootFolder);
    if length(size(img_RGB)) == 2 %Gray images algorithm.
            img_RGB = cat(3, img_RGB, img_RGB, img_RGB);%Concatenate gray image for 3 times (R, G, B).
    end
    %Start DVS algorithm using brightness compensation.
    vdd_original = 15;
    SATURATED = 1;
    %Compute original image power consumption.
    %Result is in mA.
    cell_orig = Icell (img_RGB, vdd_original);   
    %Result is mW.
    pwr_org = panelPower(cell_orig, vdd_original);     
    %Apply BrightnessCompensation dstThreshold% factor.
    tmp_DVS = LCDBrightnessCompensation (img_RGB, dstThreshold/100); 

    %Select a starting vdd_taget < vdd_original = 15V.
    vdd_target = vdd_original*(100 - dstThreshold)/100;

    %Compute tmp power.
    tmp_DVS_cell = Icell(tmp_DVS, vdd_target);
    tmp_DVS_pwr = panelPower(tmp_DVS_cell, vdd_target);
    %Apply DVS and compute distance.
    img_original_sat = displayed_image(cell_orig, vdd_original, SATURATED);
    tmp_img_DVS_sat = displayed_image(tmp_DVS_cell, vdd_target, SATURATED);
    dst = (1 - ssim(img_original_sat, tmp_img_DVS_sat))*100;

    DVS_pwr = pwr_org;
    img_DVS_sat = img_original_sat;
    %Check if there is a local minima of vdd respecting dstThreshold.
    while tmp_DVS_pwr < DVS_pwr && dst <= dstThreshold 
        %Take new image, update DVS_pwr.
        img_DVS_sat = tmp_img_DVS_sat;
        DVS_pwr = tmp_DVS_pwr;
        %Reduce VDD.
        vdd_target = vdd_target - 0.5;
        %Recompute tmp_DVS_pwr.
        tmp_DVS_cell = Icell(tmp_DVS, vdd_target);
        tmp_DVS_pwr = panelPower(tmp_DVS_cell, vdd_target);
        %Compute new saturated image.
        tmp_img_DVS_sat = displayed_image(tmp_DVS_cell, vdd_target, SATURATED);
        dst = (1 - ssim(img_original_sat, tmp_img_DVS_sat))*100;
    end
    
    %Power / Distance exctraction.
    dst_img(i) = (1 - ssim(img_original_sat, img_DVS_sat))*100;
    energy_saving(i) = ((pwr_org - DVS_pwr)/pwr_org)*100;
 
end

mean(energy_saving)
cd (rootFolder);
%Average for dstMax 1% is  % saving.
%Average for dstMax 5% is  20.8% saving.
%Average for dstMax 10% is  29.6% saving.

%% Algorithm part 2 Contrast Enhancement.

%%
figure(1);
imshow(img_original_sat/255);      
figure(2);
imshow(img_DVS_sat/255);  
%% Reset environment.
clc
clear