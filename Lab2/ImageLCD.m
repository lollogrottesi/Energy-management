%% Find elemts in a given folder
currentFolder = pwd;
folderLst = [ "misc", "BSP" ];

myFolder = currentFolder + "\misc";
cd (myFolder);
imgLst = ls;

img_RGB = imread(imgLst(3,:), 1);
cd (currentFolder);
%Start DVS algorithm
vdd_original = 15;
vdd_target = 7;
SATURATED = 1;

%Result is in mA.
cell_orig = Icell (img_RGB, vdd_original);      
%Result is mW.
[pwr_org, pwrRGB_org] = panelPower(cell_orig, vdd_original);      

%comp_img = LCDBrightnessCompensation (img_RGB, 1 - vdd_target/vdd_original);
comp_img = LCDContrastEnhancement (img_RGB, vdd_target/vdd_original);
%comp_img = LCDCuncurrentBrightnessContrast (img_RGB, 10, 245);

cell_target = Icell(comp_img, vdd_target);
[pwr_DVS, pwrRGB_DVS] = panelPower(cell_target, vdd_original);    

pwr_saving = ((pwr_org - pwr_DVS)/pwr_org)*100
%Apply DVS on display
img_original_sat = displayed_image(cell_orig, vdd_original, SATURATED);
img_DVS_sat = displayed_image(cell_target, vdd_target, SATURATED);

dst = ImgDist (img_original_sat, img_DVS_sat)


figure(1);
image(img_original_sat/255);      
figure(2);
image(img_DVS_sat/255);       
%%
%when Apply DVS remember b = (1/vdd[original]) * vdd[new]
%when DVS for enhancement b_offstet = 1 - (1/vdd[original]) * vdd[new]
%%
cd (currentFolder)
clc
clear
%%