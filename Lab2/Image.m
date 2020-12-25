%% Find elemts in a given folder
currentFolder = pwd;
folderLst = [ "misc", "BSP" ];

myFolder = currentFolder + "\dataset";
cd (myFolder);
imgLst = ls;
%%
%[X, cmap] = imread(imgLst(3,:));
%X = imread(imgLst(3,:), 1);
clc
clearvars
%%
X = imread('test3.tiff');
%Y = hungryBlue(X, 20);
%Y = BrightnessScaling(X, 20);
Y = histeq(X);
pwrX = ImgPwr(X);
pwrY = ImgPwr(Y);
power_saving = ((pwrX - pwrY)/pwrX)*100;

figure(1);
subplot(2, 2, 1);
imshow(X);
title("Original");
subplot(2, 2, 2);
imshow(Y);
title("Optimized");
subplot(2, 2, 3);
showColorDistribution(X);
subplot(2, 2, 4);
showColorDistribution(Y);
%% Exctract RGB channels (marginal).
%Test on functions.
X = imread('test.jpg');

R = X;
R(:,:,2:3) = 0;
G = X;
G(:,:,[1 3]) = 0;
B = X;
B(:,:,1:2) = 0;

%imshow(R);

figure(1);
imhist(R);
hold on;
imhist(G);
hold on;
imhist(B);
J = histeq(X);
figure(2);
imhist(J);
figure(3);
image(X);
figure(4);
image(J);
dst = (1 - ssim(X, J))*100
%figure(1);
%imshow(X);
%imhist(X);
%figure(2);
%imshow(J);
%imhist(J);
%% GRAY IMAGE.
X_init = imread('pp.tiff');

if length(size(X_init)) == 2
    X = cat(3, X_init, X_init, X_init);
end

Y = BrightnessScaling(X, 50);
pwrX = ImgPwr (X);
pwrY = ImgPwr (Y);

powerSaving = ((pwrX - pwrY)/pwrX)*100;
dst = (1 - ssim(X, Y))*100;

figure(1)
imshow(X_init);
figure(2)
imshow(Y(:, :, 1));
%% Test hungry blue.
X = imread('pp.tiff');
pwrX = ImgPwr (X);
Y = hungryBlue(X, 50); %reduce 50% of blue.
pwrY = ImgPwr (Y);
dst = ImgDist(X, Y)
powerSaving = ((pwrX - pwrY)/pwrX)*100
figure(1)
imshow(X);
figure(2)
imshow(Y);
%% Test Brightness scaling
X = imread('test.jpg');
pwrX = ImgPwr (X)
Y = BrightnessScaling(X, 20); 
pwrY = ImgPwr (Y)
dst = ImgDist(X, Y)
figure(1)
imshow(X);
figure(2)
imshow(Y);
%% Test Brightness scaling gl - gu.
X = imread('test.jpg');
pwrX = ImgPwr (X)
Y = BrightnessScalingUpLow(X, 20, 250); 
pwrY = ImgPwr (Y)
dst = ImgDist(X, Y)
figure(1)
imshow(X);
figure(2)
imshow(Y);
%% Test algorithm
X = imread('test.tiff');
[avgR, avgG, avgB] = colorAvg(X);
bright_Avg = brightAvg(X);
max_R_G = max(avgR, avgG);

if avgB > max_R_G
    k_blue = (double(avgB - max_R_G)/double(avgB))*100;
    Y = hungryBlue(X, k_blue); %Reduce k% of blue
end

threshold = 0.01; % 1%.

if bright_Avg  > 0.5
    k_bright = (bright_Avg - bright_Avg*(1-threshold))*100;
    Z = BrightnessScaling(X, 1);%Reduce k% of brightness.
end 

%K = histeq(Z);

pwrX = ImgPwr (X);
%pwrY = ImgPwr (Y);
pwrZ = ImgPwr (Z);

powerSaving = ((pwrX - pwrZ)/pwrX)*100;
dst = (1 - ssim(X, Z))*100

figure(1)
imshow(X);
figure(2)
imshow(Z);
%%
X = imread('s0.jpg');
vdd = 12;
pwr = ImgPwr (X);
Y = LCDBrightnessCompensation (X,  (15/vdd - 1)/2);

cell_orig = Icell (Y, 15); 
X_sat = uint8(displayed_image(cell_orig, vdd, 1));
dst = ImgDist(X, X_sat);
pwr_panel = panelPower(cell_orig, vdd)/1000;
dst_ssim_ori = (1 - ssim(X, X_sat))*100;
figure(1);
imshow(X);
figure(2);
imshow(X_sat);
%%
p1 =   4.251e-05;
p2 =  -3.029e-04;
p3 =   3.024e-05;
Vdd_org = 15;
Vdd = 15;
I_cell_max = (p1 * Vdd * 1) + (p2 * 1) + p3;
image_RGB_max = (I_cell_max - p3)/(p1*Vdd_org+p2) * 255;
%%
%Start transformation algorithm for RGB.
dstThreshold = 10;
X = imread('t0.jpg');
Y = X;
pwrY_init = ImgPwr (Y);


%Histogram equalization.
Y_tmp = histeq(Y);
dist = (1 - ssim(X, Y_tmp))*100;
pwrTmp = ImgPwr (Y_tmp);
if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
    w = "Entered histEQ"
    Y = Y_tmp;
    pwrY_init = pwrTmp;
end

%Hungry blue optimization.
%Exctract color features.
[avgR, avgG, avgB] = colorAvg(Y);
max_R_G = max(avgR, avgG); 
%Reduce blue, if possible.
if avgB > max_R_G %Check if Blue average is greater than both Red and Green.
    k_blue = (double(avgB - max_R_G)/double(avgB))*100;%Percentage distance.
    Y_tmp = hungryBlue(Y, k_blue);                     %Reduce k% of blue.
    dist = (1 - ssim(X, Y_tmp))*100;
    pwrTmp = ImgPwr (Y_tmp);
    if dist <= dstThreshold && pwrTmp < pwrY_init %If possible keep transformation.
        w = "Entered hungry blue"
        Y = Y_tmp;
        pwrY_init = pwrTmp;
    end
end



%Brightness optimization.
scaling_percentage = 1;
Y_tmp = BrightnessScaling(Y, scaling_percentage);%Reduce dstThreshold% of brightness.
dist = (1 - ssim(X, Y_tmp))*100;
pwrTmp = ImgPwr (Y_tmp);

while dist <= dstThreshold && pwrTmp < pwrY_init  %If possible keep transformation.
    %w = "Entered brighness scaling"
    Y = Y_tmp;
    pwrY_init = pwrTmp;
    
    scaling_percentage = scaling_percentage + 1; %Try to scale 1% more.
    Y_tmp = BrightnessScaling(Y, scaling_percentage);%Reduce dstThreshold% of brightness.
    dist = (1 - ssim(X, Y_tmp))*100;
    pwrTmp = ImgPwr (Y_tmp);
end

%Power / Distance exctraction.
pwrX = ImgPwr (X);
pwrY = ImgPwr (Y);
dst_img = (1 - ssim(X, Y))*100;
energy_saving = ((pwrX - pwrY)/pwrX)*100;
figure(1);
imshow(X);
figure(2);
imshow(Y);
%%
%cd (currentFolder)
clc
clear 
%%