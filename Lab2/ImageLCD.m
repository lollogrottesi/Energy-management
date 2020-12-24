%% 
dstThreshold = 1;
img_RGB = imread('test_2_blue.jpg');
%showColorDistribution(img_RGB);
%Start DVS algorithm
vdd_original = 15;
%vdd_target = 14;
SATURATED = 1;

%Result is in mA.
cell_orig = Icell (img_RGB, vdd_original);   
%Result is mW.
pwr_org = panelPower(cell_orig, vdd_original);      
%Depending from vdd_target.
%comp_img = LCDBrightnessCompensation (img_RGB, 1 - vdd_target/vdd_original);
%comp_img = LCDContrastEnhancement (img_RGB, vdd_target/vdd_original);
%comp_img = LCDCuncurrentBrightnessContrast (img_RGB, 10, 245);

%comp_img = LCDBrightnessCompensation (img_RGB, dstThreshold/100);
%comp_img = LCDContrastEnhancement (img_RGB, 1 - dstThreshold/100);
%comp_img = LCDCuncurrentBrightnessContrast (img_RGB, 10, floor(255*(1-dstThreshold/100)));
%vdd_target = vdd_original*(100 - dstThreshold)/100;

tmp_DVS = LCDBrightnessCompensation (img_RGB, dstThreshold/100);

%Start vdd_target.
vdd_target = vdd_original*(100 - dstThreshold)/100;

%Compute tmp power.
tmp_DVS_cell = Icell(tmp_DVS, vdd_target);
tmp_DVS_pwr = panelPower(tmp_DVS_cell, vdd_original);
%Apply DVS and compute distance.
img_original_sat = displayed_image(cell_orig, vdd_original, SATURATED);
tmp_img_DVS_sat = displayed_image(tmp_DVS_cell, vdd_target, SATURATED);
dst = (1 - ssim(img_original_sat, tmp_img_DVS_sat))*100;

%if tmp_DVS_pwr < pwr_org && dst <= dstThreshold
%    img_DVS_sat = tmp_img_DVS_sat;
%end

%DVS_pwr = tmp_DVS_pwr;
%tmp_DVS_pwr = 0;

DVS_pwr = pwr_org;
i = 1;
while  tmp_DVS_pwr < DVS_pwr && dst <= dstThreshold 
    %Take new image, update DVS_pwr.
    img_DVS_sat = tmp_img_DVS_sat;
    DVS_pwr = tmp_DVS_pwr;
    %Reduce VDD.
    vdd_target = vdd_target - 0.5;
    %Recompute tmp_DVS_pwr.
    tmp_DVS_cell = Icell(tmp_DVS, vdd_target);
    tmp_DVS_pwr = panelPower(tmp_DVS_cell, vdd_original);
    %Compute new saturated image.
    tmp_img_DVS_sat = displayed_image(tmp_DVS_cell, vdd_target, SATURATED);
    dst = (1 - ssim(img_original_sat, tmp_img_DVS_sat))*100;
    i=i+1;
end
dst = (1 - ssim(img_original_sat, img_DVS_sat))*100;
DVS_pwr = panelPower(Icell(tmp_DVS, vdd_target), vdd_target);
power_saving = ((pwr_org-DVS_pwr)/pwr_org)*100;

figure(1);
imshow(img_original_sat/255);      
figure(2);
imshow(img_DVS_sat/255);   
%%
dstThreshold = 10;
img_RGB = imread('test_2_blue.jpg');

%Start DVS algorithm
vdd_original = 15;
vdd_step = 0.2;
SATURATED = 1;

%Result is in mA.
cell_orig = Icell (img_RGB, vdd_original);   
%Result is mW.
pwr_org = panelPower(cell_orig, vdd_original);
img_original_sat = displayed_image(cell_orig, vdd_original, SATURATED);

DVS_sat = img_original_sat;
DVS_pwr = pwr_org;

%Decrease vdd_taget.
vdd_target = vdd_original - vdd_step;

gl = -((1 - vdd_original/vdd_target)/2 * vdd_target/vdd_original);
gu = (vdd_target/vdd_original) + gl;

%Try an optimization.
%tmp_DVS = LCDBrightnessCompensation (img_RGB,  (vdd_original/vdd_target - 1)/2);
%tmp_DVS = LCDContrastEnhancement (img_RGB, vdd_target/vdd_original);
%tmp_DVS = LCDCuncurrentBrightnessContrast (img_RGB, gl, gu);

%Take the best.
%tmp_DVS = the best.
%Compute tmp power.

tmp_DVS_cell = Icell(tmp_DVS, vdd_target);
tmp_DVS_pwr = panelPower(tmp_DVS_cell, vdd_original);
%Apply DVS and compute distance.
tmp_img_DVS_sat = displayed_image(tmp_DVS_cell, vdd_target, SATURATED);

dst = (1 - ssim(img_original_sat, tmp_img_DVS_sat))*100; %Zero.
i=1;
%Decrease vdd step by step and look for a local minima.
while tmp_DVS_pwr < DVS_pwr && dst <= dstThreshold
    vdd_target = vdd_target - vdd_step;
    img_DVS_sat = tmp_img_DVS_sat;  %img_DVS_sat is an output of the loop. Rapresent the optimized image.
    DVS_pwr = tmp_DVS_pwr;          %DVS_pwr is an output of the loop. Rapresent the enrgy of the optimized image.
    %Try an optimization.
    gl = -((1 - vdd_original/vdd_target)/2 * vdd_target/vdd_original);
    gu = (vdd_target/vdd_original) + gl;

    if (gu < 0)
        gu = 0;
    elseif (gu > 1)
        gu = 1;
    end

    if (gl < 0)
        gl = 0;
    elseif (gl > 1)
        gl = 1;
    end 
    %tmp_DVS = LCDBrightnessCompensation (img_RGB, (vdd_original/vdd_target - 1)/2);
    %tmp_DVS = LCDContrastEnhancement (img_RGB, vdd_target/vdd_original);
    tmp_DVS = LCDCuncurrentBrightnessContrast (img_RGB, gl, gu);
    
    %Compute tmp power.
    tmp_DVS_cell = Icell(tmp_DVS, vdd_target);
    tmp_DVS_pwr = panelPower(tmp_DVS_cell, vdd_original);
    %Apply DVS and compute distance.
    tmp_img_DVS_sat = displayed_image(tmp_DVS_cell, vdd_target, SATURATED);
    dst = (1 - ssim(img_original_sat, tmp_img_DVS_sat))*100;
    i=i+1;
end
energy_saving = ((pwr_org - DVS_pwr)/pwr_org)*100;
dst = (1 - ssim(img_original_sat, img_DVS_sat))*100;
figure(1);
imshow(img_original_sat/255);      
figure(2);
imshow(img_DVS_sat/255);  
%%
dstThreshold = 1;
img_RGB = imread('s0.jpg');

%Start DVS algorithm.
vdd_original = 15;
vdd_step = 0.2;
SATURATED = 1;
%Compute original image power consumption.
cell_orig = Icell (img_RGB, vdd_original);   
%Result is mW.
pwr_org = panelPower(cell_orig, vdd_original);
img_RGB = uint8(displayed_image(cell_orig, vdd_original, SATURATED));
%Initialize variables.
img_DVS_sat = img_RGB;
DVS_pwr = pwr_org;

%Decrease vdd_taget.
vdd_target = vdd_original - vdd_step;
%Check the optimal transformation.
[tmp_img_DVS_sat, tmp_DVS_pwr, dst] = optimalTransformation(img_RGB, vdd_target, vdd_original, SATURATED);

while tmp_DVS_pwr < DVS_pwr && dst <= dstThreshold
    vdd_target = vdd_target - vdd_step;
    img_DVS_sat = tmp_img_DVS_sat;  %img_DVS_sat is an output of the loop. Rapresent the optimized image.
    DVS_pwr = tmp_DVS_pwr;          %DVS_pwr is an output of the loop. Rapresent the enrgy of the optimized image.
    %Check the optimal transformation.
    [tmp_img_DVS_sat, tmp_DVS_pwr, dst] = optimalTransformation(img_RGB, vdd_target, vdd_original, SATURATED);
end

%Power / Distance exctraction.

dst_img = (1 - ssim(img_RGB, img_DVS_sat))*100;
energy_saving = ((pwr_org - DVS_pwr)/pwr_org)*100;

figure(1);
imshow(img_RGB);
figure(2);
imshow(tmp_img_DVS_sat);
%%
%when Apply DVS remember b = (1/vdd[original]) * vdd[new]
%when DVS for enhancement b_offstet = 1 - (1/vdd[original]) * vdd[new]
%%
%cd (currentFolder)
clc
clear
%%